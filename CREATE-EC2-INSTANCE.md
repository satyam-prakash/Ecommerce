# Create EC2 Instance - Step by Step Guide

Follow these steps to create your EC2 instance for the Fashion Retail application.

---

## Step 1: Sign in to AWS

1. Go to: https://aws.amazon.com/console/
2. Sign in with your AWS account
3. Select region: **Asia Pacific (Mumbai) ap-south-1** (or your preferred region)

---

## Step 2: Launch EC2 Instance

### 2.1 Navigate to EC2

1. In AWS Console search bar, type **EC2**
2. Click **EC2** (Virtual Servers in the Cloud)
3. Click **Launch instance** button

### 2.2 Configure Instance

#### Name and Tags
```
Name: fashion-retail-app
```

#### Application and OS Images (Amazon Machine Image)
- **Quick Start**: Amazon Linux
- **AMI**: Amazon Linux 2023 AMI (64-bit x86)
- **Free tier eligible** ✓

#### Instance Type
- **t2.micro** (Free tier eligible - 1 vCPU, 1 GB RAM)
- OR **t3.small** (Better performance - 2 vCPU, 2 GB RAM) - ~$15/month

#### Key Pair (login)
Click **Create new key pair**:
- **Key pair name**: `fashion-retail-key`
- **Key pair type**: RSA
- **Private key file format**: .pem (for SSH)
- Click **Create key pair**
- **SAVE THE .pem FILE** - You'll need it to connect!

#### Network Settings
Click **Edit** and configure:

**Firewall (security groups)**
Create security group:
- **Name**: `fashion-retail-sg`
- **Description**: Security group for Fashion Retail app

**Inbound Security Group Rules** - Add these 3 rules:

1. **SSH** (for connecting)
   - Type: SSH
   - Protocol: TCP
   - Port: 22
   - Source: My IP (automatically fills your IP)

2. **HTTP** (for web access)
   - Type: HTTP
   - Protocol: TCP
   - Port: 80
   - Source: Anywhere (0.0.0.0/0)

3. **HTTPS** (for secure web access)
   - Type: HTTPS
   - Protocol: TCP
   - Port: 443
   - Source: Anywhere (0.0.0.0/0)

#### Configure Storage
- **Size**: 20 GB
- **Volume Type**: gp3 (General Purpose SSD)

### 2.3 Launch Instance

1. Review your configuration
2. Click **Launch instance**
3. Wait 2-3 minutes for instance to start
4. Click **View all instances**

---

## Step 3: Get Instance Details

### 3.1 Find Your Instance

In EC2 Instances page:
1. Find instance named `fashion-retail-app`
2. Wait until **Instance state** = Running
3. Wait until **Status check** = 2/2 checks passed (may take 2-3 minutes)

### 3.2 Note Important Information

Click on your instance, then note:

**Public IPv4 address**: (e.g., `13.127.45.123`) ⭐ **YOU NEED THIS!**
**Public IPv4 DNS**: (e.g., `ec2-13-127-45-123.ap-south-1.compute.amazonaws.com`)

---

## Step 4: Set Up Your EC2 Instance

### 4.1 Connect via SSH

Open PowerShell on your computer:

```powershell
# Navigate to where your .pem file is saved
cd C:\Users\praka\Downloads

# Set proper permissions on key file (important!)
icacls fashion-retail-key.pem /inheritance:r
icacls fashion-retail-key.pem /grant:r "$($env:USERNAME):(R)"

# Connect to EC2 (replace with YOUR IP)
ssh -i fashion-retail-key.pem ec2-user@YOUR_EC2_PUBLIC_IP
```

**Example:**
```powershell
ssh -i fashion-retail-key.pem ec2-user@13.127.45.123
```

Type `yes` when asked "Are you sure you want to continue connecting?"

### 4.2 Run Setup Script on EC2

Once connected to EC2, copy and paste this entire script:

```bash
#!/bin/bash
set -e

echo "========================================"
echo "Setting up Fashion Retail Application"
echo "========================================"
echo ""

# Update system
echo "Updating system packages..."
sudo yum update -y

# Install Java 21
echo "Installing Java 21..."
sudo yum install -y java-21-amazon-corretto-devel
echo "Java version:"
java -version

# Create application directory
echo "Creating application directory..."
sudo mkdir -p /opt/fashion-retail
sudo chown ec2-user:ec2-user /opt/fashion-retail

# Create systemd service
echo "Creating systemd service..."
sudo tee /etc/systemd/system/fashion-retail.service > /dev/null <<'EOF'
[Unit]
Description=Fashion Retail Spring Boot Application
After=syslog.target network.target

[Service]
User=ec2-user
WorkingDirectory=/opt/fashion-retail
ExecStart=/usr/bin/java -jar /opt/fashion-retail/fashion-retail-app.jar
SuccessExitStatus=143
Restart=always
RestartSec=10

# Supabase Database Configuration
Environment="SUPABASE_DB_HOST=db.pgfldlwjvjvtlyhxaiqt.supabase.co"
Environment="SUPABASE_DB_PORT=5432"
Environment="SUPABASE_DB_NAME=postgres"
Environment="SUPABASE_DB_USER=postgres.pgfldlwjvjvtlyhxaiqt"
Environment="SUPABASE_DB_PASSWORD=Saty135@"
Environment="SPRING_PROFILES_ACTIVE=prod"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable fashion-retail

# Install Nginx
echo "Installing Nginx..."
sudo yum install -y nginx

# Configure Nginx
echo "Configuring Nginx..."
sudo tee /etc/nginx/conf.d/fashion-retail.conf > /dev/null <<'NGINXEOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINXEOF

# Start Nginx
echo "Starting Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo ""
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Your EC2 instance is ready for deployment!"
echo ""
echo "Next: Deploy your application from your local machine"
echo "Run: .\deploy-to-ec2.ps1 -EC2Host \"YOUR_EC2_IP\" -SSHKey \"path\to\fashion-retail-key.pem\""
echo ""
```

Wait for script to complete (2-3 minutes).

Type `exit` to disconnect from EC2.

---

## Step 5: Deploy Your Application

### Option 1: Automated Deployment (Recommended)

Back on your Windows machine:

```powershell
# Navigate to your project
cd D:\DevopsProject

# Move your .pem file to a safe location (optional)
# mv C:\Users\praka\Downloads\fashion-retail-key.pem C:\Users\praka\.ssh\

# Deploy!
.\deploy-to-ec2.ps1 -EC2Host "YOUR_EC2_IP" -SSHKey "C:\Users\praka\Downloads\fashion-retail-key.pem"
```

**Example:**
```powershell
.\deploy-to-ec2.ps1 -EC2Host "13.127.45.123" -SSHKey "C:\Users\praka\Downloads\fashion-retail-key.pem"
```

### Option 2: Manual Deployment

```powershell
# Set Java 21
$env:JAVA_HOME="C:\Users\praka\.jdk\jdk-21.0.8"
$env:PATH="C:\Users\praka\.jdk\jdk-21.0.8\bin;$env:PATH"

# Build
mvn clean package -DskipTests

# Upload to EC2
scp -i "C:\Users\praka\Downloads\fashion-retail-key.pem" `
    target/fashion-retail-app.jar `
    ec2-user@YOUR_EC2_IP:/home/ec2-user/

# Deploy
ssh -i "C:\Users\praka\Downloads\fashion-retail-key.pem" ec2-user@YOUR_EC2_IP

# On EC2:
sudo mv /home/ec2-user/fashion-retail-app.jar /opt/fashion-retail/
sudo systemctl start fashion-retail
sudo systemctl status fashion-retail
```

---

## Step 6: Verify Deployment

### 6.1 Check Application

Open browser and go to:
```
http://YOUR_EC2_IP
```

You should see your Fashion Retail homepage! 🎉

### 6.2 Check Logs (if issues)

```powershell
ssh -i fashion-retail-key.pem ec2-user@YOUR_EC2_IP
sudo journalctl -u fashion-retail -f
```

---

## Step 7: Enable CI/CD Automation

### 7.1 Add GitHub Secrets

Now that you have EC2 running, add GitHub secrets:

1. Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions
2. Click **New repository secret**
3. Add these 3 secrets:

**Secret 1: EC2_HOST**
- Name: `EC2_HOST`
- Value: Your EC2 public IP (e.g., `13.127.45.123`)

**Secret 2: EC2_USER**
- Name: `EC2_USER`
- Value: `ec2-user`

**Secret 3: SSH_PRIVATE_KEY**
- Name: `SSH_PRIVATE_KEY`
- Value: Content of your .pem file

To get PEM file content:
```powershell
Get-Content "C:\Users\praka\Downloads\fashion-retail-key.pem" | clip
```
Then paste into GitHub secret!

### 7.2 Test Automated Deployment

```powershell
# Make a small change
echo "# Auto-deploy test" >> README.md

# Commit and push
git add .
git commit -m "Test automated deployment"
git push
```

Go to GitHub → **Actions** tab → Watch it deploy automatically! 🚀

---

## Quick Reference Card

### Your Instance Details
```
Name: fashion-retail-app
Type: t2.micro (or t3.small)
AMI: Amazon Linux 2023
Region: ap-south-1 (Mumbai)
Public IP: _______________ (write it down!)
Key File: fashion-retail-key.pem
```

### Security Group Ports
```
SSH:   22   (Your IP only)
HTTP:  80   (Anywhere)
HTTPS: 443  (Anywhere)
```

### Important Commands
```powershell
# Connect to EC2
ssh -i fashion-retail-key.pem ec2-user@YOUR_EC2_IP

# Deploy application
.\deploy-to-ec2.ps1 -EC2Host "YOUR_EC2_IP" -SSHKey "path\to\key.pem"

# View logs on EC2
sudo journalctl -u fashion-retail -f

# Restart service on EC2
sudo systemctl restart fashion-retail
```

### URLs
```
Application: http://YOUR_EC2_IP
Health Check: http://YOUR_EC2_IP/actuator/health
AWS Console: https://console.aws.amazon.com/ec2/
```

---

## Cost Estimate

### Free Tier (First 12 Months)
- **t2.micro**: FREE (750 hours/month)
- **20 GB Storage**: FREE (30 GB included)
- **Data Transfer**: FREE (15 GB/month outbound)

**Total: $0/month** for first year! 🎉

### After Free Tier
- **t2.micro**: ~$8/month
- **t3.small**: ~$15/month (recommended for production)
- **20 GB Storage**: ~$2/month
- **Data Transfer**: First 100 GB free/month

**Estimated: $10-17/month**

---

## Troubleshooting

### Can't connect via SSH
- Check security group allows port 22 from your IP
- Verify you're using correct .pem file
- Run permission command: `icacls key.pem /inheritance:r`

### Application won't start
- Check Supabase database is not paused
- Check logs: `sudo journalctl -u fashion-retail -n 100`
- Verify JAR file exists: `ls -lh /opt/fashion-retail/`

### Can't access website
- Check security group allows port 80 from anywhere
- Check Nginx: `sudo systemctl status nginx`
- Check app: `curl http://localhost:8080`

### Instance stopped unexpectedly
- Check AWS billing (free tier limits)
- Check instance type (t2.micro can stop if overloaded)
- Consider upgrading to t3.small

---

## Next Steps After EC2 is Running

1. ✅ EC2 instance created and running
2. ✅ Application deployed
3. ✅ GitHub secrets configured
4. ✅ CI/CD pipeline active

**Now every time you push code:**
```powershell
git push
```
**It deploys automatically in 5 minutes!** 🎊

---

## Security Best Practices

1. **Never commit .pem files** to Git (already in .gitignore ✓)
2. **Keep .pem file safe** - store in `C:\Users\praka\.ssh\`
3. **Use strong passwords** for Supabase
4. **Enable HTTPS** with Let's Encrypt (optional)
5. **Regular updates**: `sudo yum update -y` monthly
6. **Monitor costs** in AWS Billing Dashboard

---

## Support Resources

- **AWS EC2 Documentation**: https://docs.aws.amazon.com/ec2/
- **AWS Free Tier**: https://aws.amazon.com/free/
- **Spring Boot on EC2**: See EC2-DEPLOYMENT-GUIDE.md
- **CI/CD Setup**: See CI-CD-SETUP.md

---

**Ready to create your EC2 instance? Follow the steps above! 🚀**

**Estimated time: 15 minutes** from instance creation to live application!
