# Supabase Connection Test Script
# Run this to diagnose Supabase connectivity issues

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Supabase Connection Test" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if Java is accessible
Write-Host "Test 1: Checking Java..." -ForegroundColor Yellow
$javaVersion = java -version 2>&1 | Select-String "version"
if ($javaVersion) {
    Write-Host "✓ Java found: $javaVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Java not found" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 2: Test network connectivity to Supabase
Write-Host "Test 2: Testing Supabase host connectivity..." -ForegroundColor Yellow
$supabaseHost = "db.pgfldlwjvjvtlyhxaiqt.supabase.co"
$port = 5432

Write-Host "  Testing: $supabaseHost on port $port" -ForegroundColor Gray
try {
    $connection = Test-NetConnection -ComputerName $supabaseHost -Port $port -WarningAction SilentlyContinue
    if ($connection.TcpTestSucceeded) {
        Write-Host "✓ Connection to Supabase successful!" -ForegroundColor Green
        Write-Host "  Remote Address: $($connection.RemoteAddress)" -ForegroundColor Gray
    } else {
        Write-Host "✗ Cannot connect to Supabase" -ForegroundColor Red
        Write-Host "  This might be due to:" -ForegroundColor Yellow
        Write-Host "    - Firewall blocking the connection" -ForegroundColor Gray
        Write-Host "    - VPN required" -ForegroundColor Gray
        Write-Host "    - Database paused/unavailable" -ForegroundColor Gray
        Write-Host "    - Network issue" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Recommendation: Use H2 in-memory database for local testing" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Error testing connection: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Check if database is paused
Write-Host "Test 3: Checking database status..." -ForegroundColor Yellow
Write-Host "  Please check manually at:" -ForegroundColor Gray
Write-Host "  https://supabase.com/dashboard/project/pgfldlwjvjvtlyhxaiqt" -ForegroundColor Cyan
Write-Host ""

# Test 4: Verify credentials are set
Write-Host "Test 4: Checking environment variables..." -ForegroundColor Yellow
$envVars = @{
    "SUPABASE_DB_HOST" = $env:SUPABASE_DB_HOST
    "SUPABASE_DB_USER" = $env:SUPABASE_DB_USER
    "SUPABASE_DB_PASSWORD" = if ($env:SUPABASE_DB_PASSWORD) { "***SET***" } else { $null }
}

foreach ($var in $envVars.GetEnumerator()) {
    if ($var.Value) {
        Write-Host "  ✓ $($var.Key): $($var.Value)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($var.Key): NOT SET" -ForegroundColor Red
    }
}
Write-Host ""

# Recommendation
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Recommendations:" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

if ($connection -and $connection.TcpTestSucceeded) {
    Write-Host "Good news! Network connection works." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Verify your database password is correct" -ForegroundColor White
    Write-Host "2. Check database is not paused in Supabase dashboard" -ForegroundColor White
    Write-Host "3. Try running with prod profile:" -ForegroundColor White
    Write-Host "   `$env:SPRING_PROFILES_ACTIVE='prod'; .\start-local.ps1" -ForegroundColor Cyan
} else {
    Write-Host "Network connection failed." -ForegroundColor Red
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "1. Use H2 in-memory database (recommended for local dev):" -ForegroundColor White
    Write-Host "   .\start-local.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. Check your firewall settings" -ForegroundColor White
    Write-Host "3. Try using VPN if required by your network" -ForegroundColor White
    Write-Host "4. Verify database is active in Supabase dashboard" -ForegroundColor White
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
