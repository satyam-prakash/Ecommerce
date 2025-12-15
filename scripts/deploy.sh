#!/bin/bash

# Deployment script for Fashion Retail Application
# This script should be run from your local machine or CI/CD pipeline

set -e

# Configuration
EC2_HOST="${EC2_HOST:-your-ec2-ip}"
EC2_USER="${EC2_USER:-ec2-user}"
SSH_KEY="${SSH_KEY:-~/.ssh/your-key.pem}"
JAR_FILE="target/fashion-retail-app.jar"

echo "=== Fashion Retail Deployment Script ==="
echo "EC2 Host: $EC2_HOST"
echo "EC2 User: $EC2_USER"
echo ""

# Check if JAR file exists
if [ ! -f "$JAR_FILE" ]; then
    echo "Error: JAR file not found at $JAR_FILE"
    echo "Building application..."
    mvn clean package -DskipTests
fi

# Copy JAR to EC2
echo "Copying JAR file to EC2..."
scp -i "$SSH_KEY" "$JAR_FILE" "$EC2_USER@$EC2_HOST:/home/$EC2_USER/"

# Deploy on EC2
echo "Deploying application on EC2..."
ssh -i "$SSH_KEY" "$EC2_USER@$EC2_HOST" << 'ENDSSH'
    # Stop the service
    sudo systemctl stop fashion-retail || true
    
    # Move JAR to application directory
    sudo mv /home/$USER/fashion-retail-app.jar /opt/fashion-retail/
    sudo chown $USER:$USER /opt/fashion-retail/fashion-retail-app.jar
    
    # Start the service
    sudo systemctl start fashion-retail
    
    # Wait a moment for the service to start
    sleep 5
    
    # Check status
    sudo systemctl status fashion-retail --no-pager
    
    # Show recent logs
    echo ""
    echo "=== Recent logs ==="
    sudo journalctl -u fashion-retail -n 20 --no-pager
ENDSSH

echo ""
echo "=== Deployment Complete! ==="
echo "Application should be accessible at http://$EC2_HOST"
echo ""
echo "To check logs: ssh -i $SSH_KEY $EC2_USER@$EC2_HOST 'sudo journalctl -u fashion-retail -f'"
