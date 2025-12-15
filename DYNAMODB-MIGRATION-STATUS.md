# DynamoDB Migration Status

## ✅ Completed
1. **pom.xml** - Replaced JPA/Hibernate with AWS DynamoDB SDK v2 Enhanced Client
2. **User.java** - Converted to DynamoDB model with @DynamoDbBean and partition key
3. **Product.java** - Converted to DynamoDB model
4. **Order.java** - Converted to DynamoDB model with nested OrderItem list
5. **OrderItem.java** - Converted to DynamoDB nested bean (no separate table)
6. **CartItem.java** - Converted to DynamoDB model with composite key (userId + productId)
7. **DynamoDBConfig.java** - Created configuration for AWS SDK and table beans
8. **All Repositories** - Converted from JpaRepository interfaces to concrete DynamoDB repository classes
9. **application.properties** - Removed JPA/Hibernate configs, added AWS DynamoDB configuration

## ⏳ In Progress
**Service Layer Updates** - Need to:
- Remove `@Transactional` annotations (4 files)
- Update method calls from JPA-style to DynamoDB-style:
  - Change `Long` IDs to `String` IDs
  - Update `findById()` to work with String IDs
  - Update relationship handling (User-Product-Order now use IDs instead of objects)
  - Update `CustomUserDetailsService` to work with new User model

## 🚧 Remaining Tasks

### High Priority:
1. **Update Services** (UserService, ProductService, OrderService, CartService, CustomUserDetailsService)
   - Remove @Transactional and import
   - Change all Long id parameters to String
   - Update entity relationships (e.g., `order.getUser().getId()` → `order.getUserId()`)
   - Update CartItem to use productId instead of Product object
   
2. **Update Controllers** (AuthController, ProductController, OrderController, CartController)
   - Change Long id parameters to String in path variables
   - Update DTOs if they reference Long IDs
   
3. **Test the Build**
   - Compile and fix remaining errors
   - Create DynamoDB tables in AWS
   - Add AWS credentials to EC2

### AWS Setup Required:
1. Create DynamoDB tables:
   - User (Partition Key: id)
   - Product (Partition Key: id)
   - Order (Partition Key: id)
   - CartItem (Partition Key: userId, Sort Key: productId)

2. Configure AWS Credentials on EC2:
   - Use IAM Role (recommended) or
   - Set environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY

3. Set region in application.properties or environment: aws.region=ap-south-1

## Key Changes from JPA to DynamoDB:

### ID Changes:
- **Before**: `Long id` (auto-increment)
- **After**: `String id` (UUID)

### Relationships:
- **Before**: `@ManyToOne` with object references (e.g., `order.getUser()`)
- **After**: String foreign keys (e.g., `order.getUserId()`)

### Queries:
- **Before**: JPA query methods (e.g., `findByUser(User user)`)
- **After**: DynamoDB scan/query with filters (e.g., `findByUserId(String userId)`)

### Transactions:
- **Before**: `@Transactional` for ACID operations
- **After**: DynamoDB transactions (optional, requires DynamoDB Transaction API)

## Next Steps:
1. Remove all `@Transactional` annotations
2. Update all services to use String IDs
3. Update controllers to accept String IDs
4. Build and test locally
5. Create DynamoDB tables in AWS
6. Deploy to EC2 with IAM role or credentials
