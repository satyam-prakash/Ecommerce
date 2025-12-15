# Fashion Retail E-Commerce - Start Script
# Run this script to start the application locally with H2 database

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Fashion Retail E-Commerce App" -ForegroundColor Cyan
Write-Host "Java 21 LTS" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Set Java 21
$env:JAVA_HOME = "C:\Users\praka\.jdk\jdk-21.0.8"
$env:PATH = "C:\Users\praka\.jdk\jdk-21.0.8\bin;$env:PATH"

# Set local profile (H2 database)
$env:SPRING_PROFILES_ACTIVE = "local"

Write-Host "✓ Using Java 21 LTS" -ForegroundColor Green
Write-Host "✓ Using H2 in-memory database" -ForegroundColor Green
Write-Host ""
Write-Host "Starting application..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Once started, access:" -ForegroundColor Cyan
Write-Host "  Application: http://localhost:8080" -ForegroundColor White
Write-Host "  H2 Console:  http://localhost:8080/h2-console" -ForegroundColor White
Write-Host ""
Write-Host "Test Credentials:" -ForegroundColor Cyan
Write-Host "  Email:    test@example.com" -ForegroundColor White
Write-Host "  Password: password123" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the application" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Start the application
mvn spring-boot:run
