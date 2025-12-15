# EC2 Deployment Script for Windows
# Run this from your local Windows machine

param(
    [string]$EC2Host = "",
    [string]$EC2User = "ec2-user",
    [string]$SSHKey = "",
    [switch]$BuildFirst = $true
)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Fashion Retail EC2 Deployment" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if configuration is provided
if (-not $EC2Host -or -not $SSHKey) {
    Write-Host "Missing required parameters!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host '  .\deploy-to-ec2.ps1 -EC2Host "13.127.45.123" -SSHKey "C:\path\to\key.pem"' -ForegroundColor Gray
    Write-Host ""
    Write-Host "Optional parameters:" -ForegroundColor Yellow
    Write-Host "  -EC2User <username>     (default: ec2-user)" -ForegroundColor Gray
    Write-Host "  -BuildFirst:`$false      (skip Maven build)" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Verify SSH key exists
if (-not (Test-Path $SSHKey)) {
    Write-Host "Error: SSH key not found at: $SSHKey" -ForegroundColor Red
    exit 1
}

# Set Java 21 environment
Write-Host "Setting up Java 21 environment..." -ForegroundColor Yellow
$env:JAVA_HOME = "C:\Users\praka\.jdk\jdk-21.0.8"
$env:PATH = "C:\Users\praka\.jdk\jdk-21.0.8\bin;$env:PATH"

# Build application
if ($BuildFirst) {
    Write-Host ""
    Write-Host "Building application..." -ForegroundColor Yellow
    mvn clean package -DskipTests
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
}

# Verify JAR exists
$jarFile = "target\fashion-retail-app.jar"
if (-not (Test-Path $jarFile)) {
    Write-Host "Error: JAR file not found at $jarFile" -ForegroundColor Red
    Write-Host "Run with -BuildFirst to build the application" -ForegroundColor Yellow
    exit 1
}

$jarSize = (Get-Item $jarFile).Length / 1MB
Write-Host "JAR file ready: $([math]::Round($jarSize, 2)) MB" -ForegroundColor Green

# Upload JAR to EC2
Write-Host ""
Write-Host "Uploading JAR to EC2..." -ForegroundColor Yellow
Write-Host "Target: $EC2User@$EC2Host" -ForegroundColor Gray

scp -i "$SSHKey" "$jarFile" "${EC2User}@${EC2Host}:/home/${EC2User}/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Upload failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  - Check EC2 security group allows SSH (port 22) from your IP" -ForegroundColor Gray
    Write-Host "  - Verify SSH key permissions" -ForegroundColor Gray
    Write-Host "  - Ensure EC2 public IP is correct" -ForegroundColor Gray
    exit 1
}

Write-Host "Upload complete" -ForegroundColor Green

# Deploy on EC2
Write-Host ""
Write-Host "Deploying application on EC2..." -ForegroundColor Yellow

# Create temporary deployment script with LF line endings
$tempScript = [System.IO.Path]::GetTempFileName()
$deployCommands = @"
#!/bin/bash
echo "=== Deploying Fashion Retail Application ==="

# Stop service
echo "Stopping service..."
sudo systemctl stop fashion-retail 2>/dev/null || true

# Clean up old files
echo "Cleaning up old files..."
sudo rm -f /opt/fashion-retail/*

# Move JAR with correct name
echo "Moving JAR to application directory..."
sudo cp /home/ec2-user/fashion-retail-app.jar /opt/fashion-retail/fashion-retail-app.jar
sudo chown ec2-user:ec2-user /opt/fashion-retail/fashion-retail-app.jar
sudo chmod 644 /opt/fashion-retail/fashion-retail-app.jar

# Verify JAR
echo "Verifying JAR file..."
ls -lh /opt/fashion-retail/

# Start service
echo "Starting service..."
sudo systemctl daemon-reload
sudo systemctl start fashion-retail

# Wait for startup
echo "Waiting for application to start..."
sleep 10

# Check status
echo ""
echo "=== Service Status ==="
sudo systemctl status fashion-retail --no-pager -l || true

echo ""
echo "=== Recent Logs ==="
sudo journalctl -u fashion-retail -n 20 --no-pager

echo ""
echo "=== Health Check ==="
curl -s http://localhost:8080/actuator/health || echo "Health check endpoint not responding yet"

echo ""
echo "=== Deployment Complete ==="
"@

# Write with Unix line endings (LF only)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($tempScript, $deployCommands.Replace("`r`n", "`n"), $utf8NoBom)

# Copy script to EC2 and execute
scp -i "$SSHKey" "$tempScript" "${EC2User}@${EC2Host}:/tmp/deploy.sh"
ssh -i "$SSHKey" "${EC2User}@${EC2Host}" "chmod +x /tmp/deploy.sh && /tmp/deploy.sh && rm /tmp/deploy.sh"

# Clean up local temp file
Remove-Item $tempScript -ErrorAction SilentlyContinue

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Deployment had issues. Check the output above." -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "Deployment Successful!" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Access your application at:" -ForegroundColor Yellow
    Write-Host "  http://$EC2Host" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To view logs in real-time:" -ForegroundColor Yellow
    Write-Host "  ssh -i `"$SSHKey`" $EC2User@$EC2Host" -ForegroundColor Gray
    Write-Host "  sudo journalctl -u fashion-retail -f" -ForegroundColor Gray
    Write-Host ""
}
