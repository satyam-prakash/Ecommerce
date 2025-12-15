# AWS DynamoDB Setup Guide

## ✅ Application is Ready for DynamoDB!

Your Fashion Retail application has been successfully migrated to AWS DynamoDB.

## Required AWS Resources

### 1. Create DynamoDB Tables

Go to AWS Console → DynamoDB → Tables → Create table

#### Table 1: User
- **Table name**: `User`
- **Partition key**: `id` (String)
- **Settings**: On-demand or Provisioned (5 RCU, 5 WCU for free tier)

Optional: Add Global Secondary Index (GSI) for email lookups:
- **Index name**: `EmailIndex`
- **Partition key**: `email` (String)

#### Table 2: Product
- **Table name**: `Product`
- **Partition key**: `id` (String)
- **Settings**: On-demand or Provisioned (5 RCU, 5 WCU)

#### Table 3: Order
- **Table name**: `Order`
- **Partition key**: `id` (String)
- **Settings**: On-demand or Provisioned (5 RCU, 5 WCU)

Optional: Add GSI for userId lookups:
- **Index name**: `UserIdIndex`
- **Partition key**: `userId` (String)

#### Table 4: CartItem
- **Table name**: `CartItem`
- **Partition key**: `userId` (String)
- **Sort key**: `productId` (String)
- **Settings**: On-demand or Provisioned (5 RCU, 5 WCU)

## AWS Credentials Setup

### Option 1: IAM Role (Recommended for EC2)

1. Create IAM Role:
   - Go to AWS Console → IAM → Roles → Create role
   - Choose "AWS service" → Select "EC2"
   - Add permissions:
     - `AmazonDynamoDBFullAccess` (or create custom policy)
   
2. Attach Role to EC2 Instance:
   - Go to EC2 Console → Select your instance (13.203.227.237)
   - Actions → Security → Modify IAM role
   - Select the role you created

3. **No code changes needed!** The application will automatically use the IAM role.

### Option 2: Environment Variables (Alternative)

Add to EC2 `/etc/systemd/system/fashion-retail.service`:

```ini
Environment="AWS_ACCESS_KEY_ID=your-access-key"
Environment="AWS_SECRET_ACCESS_KEY=your-secret-key"
Environment="AWS_REGION=ap-south-1"
```

## Quick Start Script

Run this on your local machine to create all tables:

```bash
# Install AWS CLI first: https://aws.amazon.com/cli/

# Configure AWS credentials
aws configure

# Create User table
aws dynamodb create-table \
    --table-name User \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region ap-south-1

# Create Product table
aws dynamodb create-table \
    --table-name Product \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region ap-south-1

# Create Order table
aws dynamodb create-table \
    --table-name Order \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region ap-south-1

# Create CartItem table
aws dynamodb create-table \
    --table-name CartItem \
    --attribute-definitions \
        AttributeName=userId,AttributeType=S \
        AttributeName=productId,AttributeType=S \
    --key-schema \
        AttributeName=userId,KeyType=HASH \
        AttributeName=productId,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --region ap-south-1
```

## Deployment to EC2

1. **Build the application:**
   ```powershell
   mvn clean package -DskipTests
   ```

2. **Deploy to EC2:**
   ```powershell
   .\deploy-to-ec2.ps1 -EC2Host "13.203.227.237" -SSHKey "C:\Users\praka\Downloads\fashion-retail-key.pem"
   ```

3. **Update EC2 service (if using IAM Role):**
   ```bash
   ssh -i "fashion-retail-key.pem" ec2-user@13.203.227.237
   
   # Update service to remove H2 profile
   sudo sed -i 's/SPRING_PROFILES_ACTIVE=local//' /etc/systemd/system/fashion-retail.service
   sudo systemctl daemon-reload
   sudo systemctl restart fashion-retail
   
   # Check logs
   sudo journalctl -u fashion-retail -f
   ```

## Testing Locally (Optional)

To test locally without AWS, use DynamoDB Local:

1. Download DynamoDB Local:
   ```bash
   docker run -p 8000:8000 amazon/dynamodb-local
   ```

2. Update `application.properties`:
   ```properties
   aws.dynamodb.endpoint=http://localhost:8000
   aws.region=us-east-1
   aws.accessKeyId=dummy
   aws.secretKey=dummy
   ```

3. Run the application:
   ```bash
   mvn spring-boot:run
   ```

## Cost Estimate

With AWS Free Tier (first 12 months):
- **DynamoDB**: 25 GB storage + 25 RCU/WCU = FREE
- **EC2**: t2.micro 750 hours/month = FREE
- **Data Transfer**: First 1 GB/month = FREE

Estimated cost after free tier: $5-10/month with low traffic

## Migration Checklist

- [x] Models converted to DynamoDB beans
- [x] Repositories converted to DynamoDB
- [x] Services updated for String IDs
- [x] Controllers updated for String IDs
- [x] Application properties configured
- [x] Application builds successfully
- [ ] Create DynamoDB tables in AWS
- [ ] Configure IAM role on EC2
- [ ] Deploy to EC2
- [ ] Test API endpoints

## Troubleshooting

### "User table does not exist"
→ Create the tables using the commands above

### "The security token included in the request is invalid"
→ Configure AWS credentials (IAM role or environment variables)

### "Unable to load credentials from any provider"
→ Ensure IAM role is attached to EC2 instance

### Application starts but no data
→ DynamoDB tables are empty. Add sample data or use the API to create records.

## Sample Data (Optional)

You can add sample products using the API or AWS Console:

```json
{
  "name": "Blue T-Shirt",
  "description": "Comfortable cotton t-shirt",
  "price": 29.99,
  "category": "Clothing",
  "stockQuantity": 100,
  "active": true
}
```

POST to: `http://13.203.227.237/api/products`

## Next Steps

1. Create DynamoDB tables (use Quick Start Script above)
2. Attach IAM role to EC2 instance
3. Deploy the new build to EC2
4. Test the application!

Your application is now ready for production with AWS DynamoDB! 🚀
