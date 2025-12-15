#!/bin/bash

# EC2 Setup Script for Fashion Retail Application
# Run this script on your EC2 instance to set up the environment

set -e

echo "=== Fashion Retail EC2 Setup Script ==="

# Update system
echo "Updating system packages..."
sudo yum update -y

# Install Java 21
echo "Installing Java 21..."
sudo yum install -y java-21-amazon-corretto-devel

# Verify Java installation
java -version

# Create application directory
echo "Creating application directory..."
sudo mkdir -p /opt/fashion-retail
sudo chown $USER:$USER /opt/fashion-retail

# Create systemd service file
echo "Creating systemd service..."
sudo tee /etc/systemd/system/fashion-retail.service > /dev/null <<EOF
[Unit]
Description=Fashion Retail Spring Boot Application
After=syslog.target network.target

[Service]
User=$USER
WorkingDirectory=/opt/fashion-retail
ExecStart=/usr/bin/java -jar /opt/fashion-retail/fashion-retail-app.jar
SuccessExitStatus=143
Restart=always
RestartSec=10

# Environment variables
Environment="SUPABASE_DB_HOST=your-supabase-host"
Environment="SUPABASE_DB_NAME=postgres"
Environment="SUPABASE_DB_USER=postgres"
Environment="SUPABASE_DB_PASSWORD=your-password"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Install Nginx
echo "Installing Nginx..."
sudo yum install -y nginx

# Configure Nginx as reverse proxy
echo "Configuring Nginx..."
sudo tee /etc/nginx/conf.d/fashion-retail.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Start and enable Nginx
echo "Starting Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure firewall (if using firewalld)
if command -v firewall-cmd &> /dev/null; then
    echo "Configuring firewall..."
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --reload
fi

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Edit /etc/systemd/system/fashion-retail.service with your Supabase credentials"
echo "2. Copy your JAR file to /opt/fashion-retail/fashion-retail-app.jar"
echo "3. Start the service: sudo systemctl start fashion-retail"
echo "4. Check status: sudo systemctl status fashion-retail"
echo "5. Enable on boot: sudo systemctl enable fashion-retail"
echo ""
echo "To view logs: sudo journalctl -u fashion-retail -f"
