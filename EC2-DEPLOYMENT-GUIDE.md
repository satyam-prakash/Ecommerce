# EC2 Deployment Guide - Fashion Retail Application

Complete guide to deploy your Java 21 Spring Boot application on AWS EC2.

---

## Prerequisites

- AWS Account
- EC2 instance (Amazon Linux 2 or Ubuntu)
- SSH key pair (.pem file)
- Supabase database credentials
- Local machine with Maven and Java 21 installed

---

## Step 1: Launch EC2 Instance

### 1.1 Create EC2 Instance in AWS Console

1. Go to AWS Console → EC2 → Launch Instance
2. **Name**: `fashion-retail-app`
3. **AMI**: Amazon Linux 2023 or Amazon Linux 2
4. **Instance Type**: `t2.micro` (free tier) or `t3.small` (recommended for production)
5. **Key Pair**: Create new or select existing
6. **Network Settings**:
   - Allow SSH (port 22) from your IP
   - Allow HTTP (port 80) from anywhere (0.0.0.0/0)
   - Allow HTTPS (port 443) from anywhere (0.0.0.0/0)
7. **Storage**: 20 GB GP3
8. Click **Launch Instance**

### 1.2 Note Your Instance Details

```
EC2 Public IP: xxx.xxx.xxx.xxx
SSH Key: your-key.pem
```

---

## Step 2: Build Application Locally

### 2.1 Package the Application

```powershell
# Set Java 21
$env:JAVA_HOME="C:\Users\praka\.jdk\jdk-21.0.8"
$env:PATH="C:\Users\praka\.jdk\jdk-21.0.8\bin;$env:PATH"

# Build JAR file (skip tests to speed up)
mvn clean package -DskipTests
```

This creates: `target/fashion-retail-app.jar`

### 2.2 Verify JAR File

```powershell
# Check file exists
Test-Path target/fashion-retail-app.jar

# Check file size (should be ~50-100MB)
(Get-Item target/fashion-retail-app.jar).Length / 1MB
```

---

## Step 3: Set Up EC2 Instance

### 3.1 Connect to EC2

**From Windows PowerShell:**

```powershell
# Set proper permissions on key file (first time only)
icacls "path\to\your-key.pem" /inheritance:r
icacls "path\to\your-key.pem" /grant:r "$($env:USERNAME):(R)"

# Connect via SSH
ssh -i "path\to\your-key.pem" ec2-user@your-ec2-public-ip
```

**Example:**
```powershell
ssh -i "C:\Users\praka\.ssh\my-key.pem" ec2-user@13.127.45.123
```

### 3.2 Run Setup Script on EC2

Once connected to EC2, run:

```bash
# Download setup script
curl -o setup.sh https://raw.githubusercontent.com/yourusername/yourrepo/main/scripts/ec2-setup.sh

# Or manually create it
nano setup.sh
# Paste the content from scripts/ec2-setup.sh
# Press Ctrl+X, then Y, then Enter

# Make executable
chmod +x setup.sh

# Run setup
./setup.sh
```

This installs:
- Java 21
- Nginx (reverse proxy)
- Systemd service configuration

---

## Step 4: Upload Application

### 4.1 Copy JAR to EC2

**From your Windows machine (PowerShell):**

```powershell
# Copy JAR file
scp -i "path\to\your-key.pem" target/fashion-retail-app.jar ec2-user@your-ec2-ip:/home/ec2-user/
```

**Example:**
```powershell
scp -i "C:\Users\praka\.ssh\my-key.pem" target/fashion-retail-app.jar ec2-user@13.127.45.123:/home/ec2-user/
```

### 4.2 Move JAR to Application Directory

**On EC2:**

```bash
# Move JAR to app directory
sudo mv /home/ec2-user/fashion-retail-app.jar /opt/fashion-retail/
sudo chown ec2-user:ec2-user /opt/fashion-retail/fashion-retail-app.jar
```

---

## Step 5: Configure Environment Variables

### 5.1 Edit Systemd Service File

**On EC2:**

```bash
sudo nano /etc/systemd/system/fashion-retail.service
```

Update the environment variables with your Supabase credentials:

```ini
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

# Environment Variables - UPDATE THESE!
Environment="SUPABASE_DB_HOST=db.pgfldlwjvjvtlyhxaiqt.supabase.co"
Environment="SUPABASE_DB_PORT=5432"
Environment="SUPABASE_DB_NAME=postgres"
Environment="SUPABASE_DB_USER=postgres.pgfldlwjvjvtlyhxaiqt"
Environment="SUPABASE_DB_PASSWORD=Saty135@"
Environment="SPRING_PROFILES_ACTIVE=prod"

[Install]
WantedBy=multi-user.target
```

Press `Ctrl+X`, then `Y`, then `Enter` to save.

### 5.2 Reload Systemd

```bash
sudo systemctl daemon-reload
```

---

## Step 6: Start Application

### 6.1 Start the Service

```bash
# Start application
sudo systemctl start fashion-retail

# Check status
sudo systemctl status fashion-retail

# Enable auto-start on boot
sudo systemctl enable fashion-retail
```

### 6.2 View Logs

```bash
# View real-time logs
sudo journalctl -u fashion-retail -f

# View last 100 lines
sudo journalctl -u fashion-retail -n 100

# Press Ctrl+C to exit log view
```

---

## Step 7: Verify Deployment

### 7.1 Check Application Health

**On EC2:**

```bash
# Check if app is running on port 8080
curl http://localhost:8080

# Check Nginx
curl http://localhost
```

### 7.2 Access from Browser

Open your browser and navigate to:

```
http://your-ec2-public-ip
```

You should see the Fashion Retail homepage!

---

## Step 8: (Optional) Set Up Domain Name

### 8.1 Configure Route 53

1. Go to AWS Route 53
2. Create hosted zone for your domain
3. Add A record pointing to EC2 public IP

### 8.2 Update Nginx Configuration

```bash
sudo nano /etc/nginx/conf.d/fashion-retail.conf
```

Change `server_name _;` to:
```nginx
server_name yourdomain.com www.yourdomain.com;
```

Restart Nginx:
```bash
sudo systemctl restart nginx
```

### 8.3 (Optional) Set Up SSL with Let's Encrypt

```bash
# Install certbot
sudo yum install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal is configured automatically
```

---

## Automated Deployment Script

For subsequent deployments, use the deploy script:

### 9.1 Configure Deploy Script

Create `.env` file in project root:

```properties
EC2_HOST=13.127.45.123
EC2_USER=ec2-user
SSH_KEY=C:/Users/praka/.ssh/my-key.pem
```

### 9.2 Run Deployment

**From Windows PowerShell:**

```powershell
# Make script executable (Git Bash)
git update-index --chmod=+x scripts/deploy.sh

# Deploy
bash scripts/deploy.sh
```

Or manually:

```powershell
# Build
mvn clean package -DskipTests

# Copy to EC2
scp -i $env:SSH_KEY target/fashion-retail-app.jar ${env:EC2_USER}@${env:EC2_HOST}:/home/${env:EC2_USER}/

# Restart service via SSH
ssh -i $env:SSH_KEY ${env:EC2_USER}@${env:EC2_HOST} "sudo mv /home/ec2-user/fashion-retail-app.jar /opt/fashion-retail/ && sudo systemctl restart fashion-retail"
```

---

## Troubleshooting

### Application Won't Start

```bash
# Check logs
sudo journalctl -u fashion-retail -n 200

# Check if port 8080 is in use
sudo netstat -tulpn | grep 8080

# Test Java version
java -version

# Check JAR file
ls -lh /opt/fashion-retail/fashion-retail-app.jar
```

### Can't Connect to Supabase

```bash
# Test connectivity from EC2
curl -v telnet://db.pgfldlwjvjvtlyhxaiqt.supabase.co:5432

# Check if database is paused in Supabase dashboard
# Resume database if needed
```

### Nginx Not Working

```bash
# Check Nginx status
sudo systemctl status nginx

# Test Nginx config
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log
```

### Can't Access from Browser

1. **Check EC2 Security Group**:
   - Ensure port 80 (HTTP) is open to 0.0.0.0/0
   - Go to EC2 → Instances → Select instance → Security → Security Groups

2. **Check if app is running**:
   ```bash
   sudo systemctl status fashion-retail
   curl http://localhost:8080
   ```

3. **Check Nginx**:
   ```bash
   sudo systemctl status nginx
   curl http://localhost
   ```

---

## Useful Commands

### Service Management

```bash
# Start
sudo systemctl start fashion-retail

# Stop
sudo systemctl stop fashion-retail

# Restart
sudo systemctl restart fashion-retail

# Status
sudo systemctl status fashion-retail

# Enable auto-start
sudo systemctl enable fashion-retail

# Disable auto-start
sudo systemctl disable fashion-retail
```

### Log Management

```bash
# Real-time logs
sudo journalctl -u fashion-retail -f

# Last 100 lines
sudo journalctl -u fashion-retail -n 100

# Logs since boot
sudo journalctl -u fashion-retail -b

# Logs from specific time
sudo journalctl -u fashion-retail --since "2025-12-15 10:00:00"
```

### System Monitoring

```bash
# CPU and memory usage
htop

# Disk usage
df -h

# Check Java processes
ps aux | grep java

# Network connections
sudo netstat -tulpn | grep java
```

---

## Cost Optimization

### Free Tier Eligible

- **EC2**: t2.micro (750 hours/month free for 12 months)
- **Data Transfer**: 15 GB/month outbound free
- **EBS**: 30 GB free

### Production Recommendations

- **Instance**: t3.small or t3.medium
- **Auto Scaling**: Set up for high traffic
- **Load Balancer**: For multiple instances
- **CloudWatch**: Monitor metrics and logs
- **Backup**: Regular EBS snapshots

---

## Security Best Practices

1. **Keep dependencies updated**:
   ```bash
   sudo yum update -y
   ```

2. **Use environment variables** for secrets (never hardcode)

3. **Enable HTTPS** with SSL certificate

4. **Restrict SSH access** to your IP only

5. **Set up CloudWatch alarms** for high CPU/memory

6. **Regular backups** of database and application

7. **Use IAM roles** instead of access keys when possible

---

## Quick Reference

### Your Configuration

```
Application: Fashion Retail
Java Version: 21
Spring Boot: 3.4.0
Port: 8080 (internal), 80 (external via Nginx)
Database: Supabase PostgreSQL
JAR Location: /opt/fashion-retail/fashion-retail-app.jar
Service Name: fashion-retail
```

### URLs

```
Local Access (from EC2): http://localhost:8080
Public Access: http://your-ec2-public-ip
API Endpoints: http://your-ec2-public-ip/api/*
```

---

## Next Steps After Deployment

1. ✅ Test all application features
2. ✅ Set up monitoring with CloudWatch
3. ✅ Configure automated backups
4. ✅ Set up SSL certificate
5. ✅ Configure custom domain
6. ✅ Set up CI/CD pipeline (GitHub Actions)
7. ✅ Load testing
8. ✅ Performance optimization

---

## Support

For issues:
1. Check logs: `sudo journalctl -u fashion-retail -f`
2. Review troubleshooting section above
3. Check AWS EC2 documentation
4. Check Spring Boot documentation

---

**Deployment Complete! 🚀**

Your Fashion Retail application is now running on AWS EC2 with Java 21!
