# Script to properly format SSH key for GitHub Secret

$keyPath = "C:\Users\praka\Downloads\fashion-retail-key.pem"

Write-Host "Reading SSH key from: $keyPath" -ForegroundColor Cyan
Write-Host ""

$keyContent = Get-Content $keyPath -Raw
$keyContent = $keyContent.TrimEnd()

Write-Host "=== COPY THIS ENTIRE TEXT BLOCK BELOW (EXACTLY AS SHOWN) ===" -ForegroundColor Yellow
Write-Host ""
Write-Host $keyContent
Write-Host ""
Write-Host "=== END OF KEY - DO NOT COPY THIS LINE ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Key Statistics:" -ForegroundColor Cyan
Write-Host "  Total characters: $($keyContent.Length)"
Write-Host "  First 50 chars: $($keyContent.Substring(0, [Math]::Min(50, $keyContent.Length)))"
Write-Host "  Last 50 chars: $($keyContent.Substring([Math]::Max(0, $keyContent.Length - 50)))"
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Green
Write-Host "1. Go to: https://github.com/satyam-prakash/Ecommerce/settings/secrets/actions"
Write-Host "2. Click 'New repository secret' or update 'EC2_SSH_KEY'"
Write-Host "3. Name: EC2_SSH_KEY"
Write-Host "4. Value: Copy the text between the === markers above"
Write-Host "5. Click 'Add secret' or 'Update secret'"
Write-Host ""
Write-Host "Also verify these secrets exist:" -ForegroundColor Green
Write-Host "  - EC2_HOST: 13.203.227.237"
Write-Host "  - EC2_USER: ec2-user"
