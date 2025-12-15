# Quick Start: Deploy to EC2 in 10 Minutes

Follow these steps to deploy your Fashion Retail application to AWS EC2.

## Prerequisites Checklist

- [ ] AWS Account
- [ ] EC2 instance running (Amazon Linux 2023)
- [ ] SSH key (.pem file) downloaded
- [ ] EC2 Security Group allows:
  - Port 22 (SSH) from your IP
  - Port 80 (HTTP) from anywhere
  - Port 443 (HTTPS) from anywhere

## Step 1: Prepare EC2 (First Time Only)

### 1.1 Connect to EC2

```powershell
ssh -i "C:\path\to\your-key.pem" ec2-user@your-ec2-public-ip
```

### 1.2 Run Setup Script

Copy and paste this entire script into your EC2 terminal:

```bash
#!/bin/bash
set -e

echo "Installing Java 21..."
sudo yum update -y
sudo yum install -y java-21-amazon-corretto-devel
java -version

echo "Creating application directory..."
sudo mkdir -p /opt/fashion-retail
sudo chown ec2-user:ec2-user /opt/fashion-retail

echo "Creating systemd service..."
sudo tee /etc/systemd/system/fashion-retail.service > /dev/null <<EOF
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

echo "Installing Nginx..."
sudo yum install -y nginx

echo "Configuring Nginx..."
sudo tee /etc/nginx/conf.d/fashion-retail.conf > /dev/null <<'NGINX'
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
NGINX

sudo systemctl start nginx
sudo systemctl enable nginx

echo "Setup complete!"
```

Type `exit` to disconnect from EC2.

## Step 2: Deploy Your Application

### 2.1 Build and Deploy (Easy Way)

From your Windows machine, run:

```powershell
# Navigate to project directory
cd D:\DevopsProject

# Run deployment script
.\deploy-to-ec2.ps1 -EC2Host "YOUR_EC2_IP" -SSHKey "C:\path\to\your-key.pem"
```

**Example:**
```powershell
.\deploy-to-ec2.ps1 -EC2Host "13.127.45.123" -SSHKey "C:\Users\praka\.ssh\my-key.pem"
```

### 2.2 Deploy Manually (If Script Fails)

```powershell
# 1. Set Java 21
$env:JAVA_HOME="C:\Users\praka\.jdk\jdk-21.0.8"
$env:PATH="C:\Users\praka\.jdk\jdk-21.0.8\bin;$env:PATH"

# 2. Build
mvn clean package -DskipTests

# 3. Upload
scp -i "C:\path\to\key.pem" target/fashion-retail-app.jar ec2-user@YOUR_EC2_IP:/home/ec2-user/

# 4. Deploy (connect to EC2)
ssh -i "C:\path\to\key.pem" ec2-user@YOUR_EC2_IP

# On EC2, run:
sudo mv /home/ec2-user/fashion-retail-app.jar /opt/fashion-retail/
sudo systemctl restart fashion-retail
sudo systemctl status fashion-retail
```

## Step 3: Verify Deployment

1. **Open your browser** and go to:
   ```
   http://YOUR_EC2_IP
   ```

2. **Check logs** if something goes wrong:
   ```bash
   ssh -i "your-key.pem" ec2-user@YOUR_EC2_IP
   sudo journalctl -u fashion-retail -f
   ```

## Common Issues & Fixes

### ❌ Can't SSH to EC2

**Fix:** Check EC2 Security Group allows port 22 from your IP

### ❌ Can't access http://EC2_IP

**Fix:** Check EC2 Security Group allows port 80 from anywhere (0.0.0.0/0)

### ❌ Application won't start

**Fix:** Check logs:
```bash
ssh -i "your-key.pem" ec2-user@YOUR_EC2_IP
sudo journalctl -u fashion-retail -n 100
```

Common causes:
- Supabase database is paused (resume it)
- Wrong database credentials
- Port 8080 already in use

### ❌ Supabase connection fails

**Fix:** 
1. Go to Supabase dashboard
2. Check if database is paused
3. Click "Resume" if needed
4. Verify connection details in:
   ```bash
   sudo nano /etc/systemd/system/fashion-retail.service
   ```
5. Restart after changes:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart fashion-retail
   ```

## Update Application (Later Deployments)

Just run the deploy script again:

```powershell
.\deploy-to-ec2.ps1 -EC2Host "YOUR_EC2_IP" -SSHKey "C:\path\to\key.pem"
```

It will:
1. Build new JAR
2. Upload to EC2
3. Restart service
4. Show you the logs

## Useful Commands

### Check if running
```bash
sudo systemctl status fashion-retail
```

### View logs
```bash
sudo journalctl -u fashion-retail -f
```

### Restart service
```bash
sudo systemctl restart fashion-retail
```

### Stop service
```bash
sudo systemctl stop fashion-retail
```

---

## Need More Details?

See the full guide: [EC2-DEPLOYMENT-GUIDE.md](EC2-DEPLOYMENT-GUIDE.md)

---

## Estimated Time

- **First time setup**: 10-15 minutes
- **Subsequent deployments**: 2-3 minutes

---

**That's it! Your app is live! 🚀**

Access it at: `http://YOUR_EC2_IP`
