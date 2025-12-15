# GitHub Actions Auto-Deploy Setup

This repository uses GitHub Actions to automatically deploy the Fashion Retail application to EC2 whenever code is pushed to the main/master branch.

## Setup Instructions

### 1. Add GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

Add the following secrets:

#### EC2_HOST
```
13.203.227.237
```

#### EC2_USER
```
ec2-user
```

#### EC2_SSH_KEY
Open your SSH key file and copy the entire contents:
```bash
# On Windows PowerShell:
Get-Content C:\Users\praka\Downloads\fashion-retail-key.pem | Out-String

# Copy the entire output including:
-----BEGIN RSA PRIVATE KEY-----
... (all the key content) ...
-----END RSA PRIVATE KEY-----
```

Paste the complete key (including BEGIN and END lines) into the secret value.

### 2. Push Your Code to GitHub

```bash
# If not already a git repository
git init

# Add all files
git add .

# Commit
git commit -m "Add auto-deploy workflow"

# Add your GitHub repository as remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Push to main branch
git branch -M main
git push -u origin main
```

### 3. Verify Deployment

After pushing:
1. Go to your GitHub repository
2. Click on "Actions" tab
3. You should see the "Deploy to EC2" workflow running
4. Click on the workflow run to see detailed logs
5. Wait for the green checkmark ✅

### 4. Manual Deployment

You can also trigger deployment manually:
1. Go to Actions tab
2. Select "Deploy to EC2" workflow
3. Click "Run workflow" button
4. Select branch and click "Run workflow"

## Workflow Details

The workflow automatically:
- ✅ Checks out your code
- ✅ Sets up JDK 21
- ✅ Builds the project with Maven
- ✅ Stops the running application on EC2
- ✅ Uploads the new JAR file
- ✅ Restarts the application
- ✅ Performs health check
- ✅ Reports deployment status

## Deployment URL

After successful deployment, your application will be available at:
- **Website**: http://13.203.227.237
- **API**: http://13.203.227.237/api/products
- **Health**: http://13.203.227.237/actuator/health

## Troubleshooting

### Deployment Failed
- Check the Actions log for specific error messages
- Verify all three secrets are correctly set
- Ensure EC2 security group allows SSH (port 22) from GitHub IPs
- Verify the SSH key has correct permissions

### Application Not Starting
- SSH to EC2: `ssh -i "C:\Users\praka\Downloads\fashion-retail-key.pem" ec2-user@13.203.227.237`
- Check logs: `sudo journalctl -u fashion-retail -f`
- Check service status: `sudo systemctl status fashion-retail`

### Health Check Failed
- Increase wait time in workflow (currently 15 seconds)
- Check if DynamoDB tables exist and IAM role is configured
- Verify application.properties has correct AWS region

## Security Notes

- Never commit your SSH private key to the repository
- Always use GitHub Secrets for sensitive data
- The SSH key in secrets should match your EC2 key pair
- GitHub encrypts secrets and only exposes them to workflow runs
