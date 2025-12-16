# Fashion Retail E-Commerce - Complete Deployment Workflow

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Database Migration](#database-migration)
4. [CI/CD Pipeline](#cicd-pipeline)
5. [Application Components](#application-components)
6. [Deployment Process](#deployment-process)
7. [User Authentication Flow](#user-authentication-flow)
8. [Testing & Verification](#testing--verification)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Project Overview

**Application**: Fashion Retail E-Commerce Platform  
**Tech Stack**: Spring Boot 3.4.0, Java 21, AWS DynamoDB, HTML/CSS/JS  
**Hosting**: AWS EC2 (ap-south-1 region)  
**CI/CD**: GitHub Actions  
**Public URL**: http://13.203.227.237

---

## 🏗️ Architecture

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Browser   │────────▶│   EC2 VM     │────────▶│  DynamoDB   │
│  (Client)   │         │ Spring Boot  │         │   (NoSQL)   │
└─────────────┘         └──────────────┘         └─────────────┘
                              │
                              ▼
                        ┌──────────────┐
                        │ GitHub Push  │
                        │   Triggers   │
                        │ Auto-Deploy  │
                        └──────────────┘
```

### Components:
- **Frontend**: Static HTML/CSS/JS files served by Spring Boot
- **Backend**: REST API with Spring Security + JWT authentication
- **Database**: AWS DynamoDB (4 tables: User, Product, Order, CartItem)
- **Server**: EC2 t2.micro instance at 13.203.227.237
- **Deployment**: Automated via GitHub Actions on every push to main

---

## 🔄 Database Migration

### From: JPA/Hibernate + PostgreSQL (Supabase)
### To: AWS DynamoDB NoSQL

### Changes Made:

#### 1. **Model Layer** (5 classes converted)
- Replaced `@Entity` with `@DynamoDbBean`
- Changed `Long id` to `String id` (UUID-based)
- Replaced `@Id` with `@DynamoDbPartitionKey`
- Removed JPA annotations (`@ManyToOne`, `@OneToMany`, `@JoinColumn`)
- Changed relationships to store IDs instead of objects

**Example - User.java:**
```java
// Before: JPA
@Entity
@Id @GeneratedValue
private Long id;

// After: DynamoDB
@DynamoDbBean
@DynamoDbPartitionKey
private String id; // UUID
```

#### 2. **Repository Layer** (4 repositories converted)
- Changed from `JpaRepository` interfaces to concrete classes
- Used `DynamoDbTable<T>` for CRUD operations
- Replaced `findBy` queries with `scan()` or `query()` operations
- Added composite key support for CartItem

**Example - UserRepository.java:**
```java
// Before: JPA Interface
interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}

// After: DynamoDB Class
public class UserRepository {
    private final DynamoDbTable<User> userTable;
    
    public Optional<User> findByEmail(String email) {
        return userTable.scan().items().stream()
            .filter(u -> email.equals(u.getEmail()))
            .findFirst();
    }
}
```

#### 3. **Service Layer** (4 services updated)
- Removed `@Transactional` annotations (DynamoDB doesn't support transactions)
- Changed all `Long` IDs to `String` IDs
- Updated relationship handling (User → userId, Product → productId)

#### 4. **Configuration**
- Created `DynamoDBConfig.java` with AWS SDK v2 setup
- Removed `application.properties` JPA/datasource configs
- Added AWS region and DynamoDB endpoint configuration

#### 5. **Dependencies (pom.xml)**
```xml
<!-- Removed -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
</dependency>

<!-- Added -->
<dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>dynamodb</artifactId>
    <version>2.21.0</version>
</dependency>
<dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>dynamodb-enhanced</artifactId>
    <version>2.21.0</version>
</dependency>
```

### DynamoDB Tables Created:

1. **User Table**
   - Partition Key: `id` (String)
   - Attributes: email, password, fullName, phoneNumber, roles, enabled, createdAt

2. **Product Table**
   - Partition Key: `id` (String)
   - Attributes: name, description, price, stock, category, imageUrl, active, createdAt

3. **Order Table**
   - Partition Key: `id` (String)
   - Attributes: userId, orderItems (List), totalAmount, status, createdAt

4. **CartItem Table**
   - Partition Key: `userId` (String)
   - Sort Key: `productId` (String)
   - Attributes: quantity, addedAt

---

## 🚀 CI/CD Pipeline

### GitHub Actions Workflow (`.github/workflows/deploy.yml`)

```yaml
Trigger: Push to main/master branch
Jobs:
  1. Build with Maven (mvn clean package -DskipTests)
  2. Deploy to EC2:
     - Setup SSH
     - Stop application
     - Upload JAR file
     - Restart application
     - Health check
```

### Workflow Steps:

1. **Code Push** → GitHub detects push to `main` branch
2. **Checkout** → Actions runner clones repository
3. **Setup JDK 21** → Installs Java 21 (Temurin distribution)
4. **Maven Build** → Compiles code and creates JAR file
5. **SSH Setup** → Configures SSH keys from GitHub Secrets
6. **EC2 Connection** → Connects to 13.203.227.237 via SSH
7. **Service Stop** → `sudo systemctl stop fashion-retail`
8. **File Upload** → SCPs JAR to `/opt/fashion-retail/`
9. **Service Start** → `sudo systemctl start fashion-retail`
10. **Health Check** → Verifies `/actuator/health` endpoint
11. **Completion** → Deployment successful notification

### GitHub Secrets Required:

| Secret Name | Value | Purpose |
|------------|-------|---------|
| `EC2_HOST` | `13.203.227.237` | EC2 instance IP |
| `EC2_USER` | `ec2-user` | SSH username |
| `EC2_SSH_KEY` | Private key content | SSH authentication |

---

## 📦 Application Components

### 1. **Backend Controllers**

#### AuthController (`/api/auth`)
- `POST /register` → Create new user account
- `POST /login` → Authenticate and return JWT token

#### ProductController (`/api/products`)
- `GET /` → List all products
- `GET /{id}` → Get product by ID
- `GET /category/{category}` → Filter by category
- `POST /` → Create product (admin)
- `PUT /{id}` → Update product (admin)
- `DELETE /{id}` → Delete product (admin)

#### OrderController (`/api/orders`)
- `POST /` → Create new order
- `GET /user/{userId}` → Get user's orders
- `GET /{id}` → Get order details

#### CartController (`/api/cart`)
- `POST /add` → Add item to cart
- `GET /user/{userId}` → Get user's cart
- `PUT /{userId}/{productId}` → Update quantity
- `DELETE /{userId}/{productId}` → Remove from cart

### 2. **Frontend Pages**

- `index.html` → Homepage with featured products
- `product.html` → Product listing page
- `productDetails.html` → Individual product view
- `Account.html` → Login/Registration page **[Updated with API integration]**
- `cart.html` → Shopping cart view

### 3. **Security Configuration**

- Spring Security with BCrypt password encoding
- JWT-based authentication (stateless)
- Public endpoints: `/api/auth/**`, `/api/products/**`, static resources
- Protected endpoints: Orders, Cart operations

---

## 🔄 Deployment Process

### Automatic Deployment (GitHub Actions)

```bash
# 1. Developer makes changes
git add .
git commit -m "Your changes"
git push origin main

# 2. GitHub Actions triggers automatically
# 3. Build process starts (~30 seconds)
# 4. Deployment to EC2 (~30 seconds)
# 5. Application restarts (~15 seconds)
# Total: ~1-2 minutes
```

### Manual Deployment (If needed)

```bash
# 1. SSH to EC2
ssh -i "C:\Users\praka\Downloads\fashion-retail-key.pem" ec2-user@13.203.227.237

# 2. Stop service
sudo systemctl stop fashion-retail

# 3. Upload new JAR (from local machine)
scp -i "C:\Users\praka\Downloads\fashion-retail-key.pem" target/fashion-retail-app.jar ec2-user@13.203.227.237:/opt/fashion-retail/

# 4. Start service
sudo systemctl start fashion-retail

# 5. Check status
sudo systemctl status fashion-retail

# 6. View logs
sudo journalctl -u fashion-retail -f
```

---

## 🔐 User Authentication Flow

### Registration Process:

```
User fills form → JavaScript captures data → POST /api/auth/register
    ↓
{
    "fullName": "John Doe",
    "email": "john@example.com",
    "password": "Test123!"
}
    ↓
Backend validates → Encrypts password (BCrypt) → Saves to DynamoDB
    ↓
Response: "User registered successfully"
```

### Login Process:

```
User enters credentials → JavaScript captures data → POST /api/auth/login
    ↓
{
    "email": "john@example.com",
    "password": "Test123!"
}
    ↓
Backend authenticates → Generates JWT token → Returns response
    ↓
{
    "token": "eyJhbGciOiJIUzI1...",
    "email": "john@example.com",
    "fullName": "John Doe"
}
    ↓
JavaScript stores token in localStorage → Redirects to homepage
```

### Using Authenticated APIs:

```javascript
// Store token after login
localStorage.setItem('token', data.token);

// Use token in subsequent requests
fetch('/api/cart/add', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + localStorage.getItem('token')
    },
    body: JSON.stringify({ productId, quantity })
});
```

---

## ✅ Testing & Verification

### 1. **Health Check**
```bash
curl http://13.203.227.237/actuator/health
# Expected: {"status":"UP"}
```

### 2. **Test Registration**
```bash
curl -X POST http://13.203.227.237/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Test User","email":"test@example.com","password":"Test123!"}'
# Expected: 201 Created
```

### 3. **Test Login**
```bash
curl -X POST http://13.203.227.237/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'
# Expected: 200 OK with token
```

### 4. **Check DynamoDB Data**
```bash
# SSH to EC2 first
aws dynamodb scan --table-name User --region ap-south-1 --limit 5
aws dynamodb scan --table-name Product --region ap-south-1 --limit 5
```

### 5. **Check Application Logs**
```bash
# On EC2
sudo journalctl -u fashion-retail -f
```

---

## 🐛 Troubleshooting

### Issue 1: "502 Bad Gateway"
**Cause**: Application not running  
**Solution**:
```bash
ssh -i "key.pem" ec2-user@13.203.227.237
sudo systemctl status fashion-retail
sudo systemctl restart fashion-retail
```

### Issue 2: "Login returns 403 Forbidden"
**Cause**: User not found in database or wrong credentials  
**Solution**:
- Ensure you're using EMAIL (not username) in login form
- Hard refresh browser (Ctrl+Shift+R) to clear old HTML cache
- Register a new account if needed
- Check logs: `sudo journalctl -u fashion-retail -n 50`

### Issue 3: "GitHub Actions deployment fails"
**Cause**: SSH key or secrets not configured  
**Solution**:
- Verify all 3 secrets are set in GitHub: EC2_HOST, EC2_USER, EC2_SSH_KEY
- SSH key must be the complete private key (1678 characters)
- Check Actions logs for specific error messages

### Issue 4: "DynamoDB access denied"
**Cause**: EC2 instance IAM role not configured  
**Solution**:
```bash
# Check IAM role
aws sts get-caller-identity

# If no role, attach IAM role to EC2:
# AWS Console → EC2 → Select instance → Actions → Security → Modify IAM role
# Attach role with AmazonDynamoDBFullAccess policy
```

### Issue 5: "Application won't start after deployment"
**Cause**: Build errors or missing dependencies  
**Solution**:
```bash
# Check logs for errors
sudo journalctl -u fashion-retail -n 100

# Common issues:
# - DynamoDB tables not created
# - AWS credentials not configured
# - Port 8080 already in use
```

---

## 📊 Deployment Timeline Summary

| Phase | Duration | Status |
|-------|----------|--------|
| Database Migration (JPA → DynamoDB) | Completed | ✅ |
| Build System Update (Maven) | Completed | ✅ |
| Application Code Refactoring | Completed | ✅ |
| DynamoDB Tables Creation | Completed | ✅ |
| EC2 Deployment Setup | Completed | ✅ |
| GitHub Actions CI/CD Pipeline | Completed | ✅ |
| Authentication API Integration | Completed | ✅ |
| Frontend JavaScript Updates | Completed | ✅ |

---

## 🎉 Current Status

✅ **Application Running**: http://13.203.227.237  
✅ **CI/CD Active**: Auto-deploys on every push to main  
✅ **Database**: DynamoDB with 4 tables configured  
✅ **Authentication**: Login/Registration working  
✅ **API Endpoints**: All REST APIs functional  

---

## 📝 Next Steps (Optional Enhancements)

1. **Add Product Management UI**: Admin interface to add/edit products
2. **Implement Shopping Cart UI**: Complete cart and checkout flow
3. **Add JWT Token Refresh**: Automatic token renewal
4. **Setup HTTPS**: Configure SSL certificate with domain name
5. **Add Monitoring**: CloudWatch logs and metrics
6. **Database Indexes**: Add GSI (Global Secondary Index) for email lookup
7. **Error Handling**: Improve frontend error messages
8. **Testing**: Add unit and integration tests

---

## 📞 Support & Maintenance

### Checking Application Status:
```bash
# Health check
curl http://13.203.227.237/actuator/health

# View logs
ssh -i "key.pem" ec2-user@13.203.227.237 "sudo journalctl -u fashion-retail -f"

# Service status
ssh -i "key.pem" ec2-user@13.203.227.237 "sudo systemctl status fashion-retail"
```

### Restarting Application:
```bash
ssh -i "key.pem" ec2-user@13.203.227.237 "sudo systemctl restart fashion-retail"
```

### Viewing Database:
```bash
# List tables
aws dynamodb list-tables --region ap-south-1

# Scan users
aws dynamodb scan --table-name User --region ap-south-1 --limit 10
```

---

**Last Updated**: December 16, 2025  
**Author**: Fashion Retail Development Team  
**Version**: 1.0.0
