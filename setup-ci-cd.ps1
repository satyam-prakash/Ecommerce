# Quick Setup Script for CI/CD

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "CI/CD Setup for EC2 Deployment" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init
    git branch -M main
    Write-Host "* Git initialized" -ForegroundColor Green
} else {
    Write-Host "* Git already initialized" -ForegroundColor Green
}

# Check if GitHub Actions workflow exists
if (Test-Path ".github/workflows/deploy-ec2.yml") {
    Write-Host "* CI/CD workflow file exists" -ForegroundColor Green
} else {
    Write-Host "X CI/CD workflow file not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Get GitHub info
$hasRemote = git remote -v 2>$null
if (-not $hasRemote) {
    Write-Host "1. Create a GitHub repository" -ForegroundColor Yellow
    Write-Host "   Go to: https://github.com/new" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Add GitHub remote:" -ForegroundColor Yellow
    Write-Host "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "* Git remote configured:" -ForegroundColor Green
    git remote -v | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    Write-Host ""
}

# Check for PEM file
Write-Host "3. Prepare your EC2 SSH key (.pem file):" -ForegroundColor Yellow
$pemFiles = Get-ChildItem -Path $env:USERPROFILE -Filter "*.pem" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 5
if ($pemFiles) {
    Write-Host "   Found PEM files:" -ForegroundColor Gray
    $pemFiles | ForEach-Object { Write-Host "   - $($_.FullName)" -ForegroundColor Gray }
} else {
    Write-Host "   Download from AWS EC2 Console when creating instance" -ForegroundColor Gray
}
Write-Host ""

Write-Host "4. Add GitHub Secrets:" -ForegroundColor Yellow
Write-Host "   Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions" -ForegroundColor Gray
Write-Host ""
Write-Host "   Required secrets:" -ForegroundColor White
Write-Host "   - EC2_HOST          = Your EC2 public IP (e.g., 13.127.45.123)" -ForegroundColor Gray
Write-Host "   - EC2_USER          = ec2-user" -ForegroundColor Gray
Write-Host "   - SSH_PRIVATE_KEY   = Content of your .pem file" -ForegroundColor Gray
Write-Host ""

Write-Host "5. To view your PEM file content (copy to GitHub secret):" -ForegroundColor Yellow
Write-Host "   Get-Content 'C:\path\to\your-key.pem' | clip" -ForegroundColor Cyan
Write-Host "   (This copies to clipboard - paste into GitHub secret)" -ForegroundColor Gray
Write-Host ""

Write-Host "6. Commit and push to GitHub:" -ForegroundColor Yellow
Write-Host "   git add ." -ForegroundColor Cyan
Write-Host "   git commit -m 'Add CI/CD workflow'" -ForegroundColor Cyan
Write-Host "   git push -u origin main" -ForegroundColor Cyan
Write-Host ""

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "After Setup:" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Every time you push code:" -ForegroundColor White
Write-Host "  git push" -ForegroundColor Cyan
Write-Host ""
Write-Host "GitHub Actions will:" -ForegroundColor White
Write-Host "  * Build your application" -ForegroundColor Green
Write-Host "  * Run tests" -ForegroundColor Green
Write-Host "  * Deploy to EC2" -ForegroundColor Green
Write-Host "  * Restart the service" -ForegroundColor Green
Write-Host "  * Verify it is running" -ForegroundColor Green
Write-Host ""
Write-Host "Time: ~5 minutes from push to live!" -ForegroundColor Yellow
Write-Host ""

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Documentation:" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Full CI/CD Guide:      CI-CD-SETUP.md" -ForegroundColor Gray
Write-Host "  Quick Start EC2:       QUICK-START-EC2.md" -ForegroundColor Gray
Write-Host "  Detailed EC2 Guide:    EC2-DEPLOYMENT-GUIDE.md" -ForegroundColor Gray
Write-Host "  Troubleshooting:       SUPABASE-TROUBLESHOOTING.md" -ForegroundColor Gray
Write-Host ""

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Ready to deploy!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
