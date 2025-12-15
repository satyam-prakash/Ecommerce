# User table
aws dynamodb create-table --table-name User --attribute-definitions AttributeName=id,AttributeType=S --key-schema AttributeName=id,KeyType=HASH --billing-mode PAY_PER_REQUEST --region ap-south-1

# Product table
aws dynamodb create-table --table-name Product --attribute-definitions AttributeName=id,AttributeType=S --key-schema AttributeName=id,KeyType=HASH --billing-mode PAY_PER_REQUEST --region ap-south-1

# Order table
aws dynamodb create-table --table-name Order --attribute-definitions AttributeName=id,AttributeType=S --key-schema AttributeName=id,KeyType=HASH --billing-mode PAY_PER_REQUEST --region ap-south-1

# CartItem table (composite key)
aws dynamodb create-table --table-name CartItem --attribute-definitions AttributeName=userId,AttributeType=S AttributeName=productId,AttributeType=S --key-schema AttributeName=userId,KeyType=HASH AttributeName=productId,KeyType=RANGE --billing-mode PAY_PER_REQUEST --region ap-south-1
