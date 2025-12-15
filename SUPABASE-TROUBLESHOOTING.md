# Supabase Connectivity Troubleshooting Guide

## Current Issue
The application cannot connect to Supabase PostgreSQL database, timing out after 30 seconds.

## Quick Start - Test Connection

Run this PowerShell script to diagnose the issue:
```powershell
.\test-supabase-connection.ps1
```

---

## Option 1: Fix Supabase Connection (Production)

### Step 1: Verify Database Status
1. Open Supabase dashboard: https://supabase.com/dashboard/project/pgfldlwjvjvtlyhxaiqt
2. Check if database is **paused** (free tier databases auto-pause after 7 days of inactivity)
3. If paused, click **Resume** button

### Step 2: Get Correct Connection Details
In Supabase dashboard:
1. Go to **Settings** → **Database**
2. Copy the connection string from "Connection string" section
3. Note the password (it's not shown, you need to use the one you set)

Example connection details:
```
Host: db.pgfldlwjvjvtlyhxaiqt.supabase.co
Port: 5432
Database: postgres
User: postgres.pgfldlwjvjvtlyhxaiqt
Password: [Your Supabase project password]
```

### Step 3: Update Environment Variables
Create a file named `.env` in the project root:
```properties
SUPABASE_DB_HOST=db.pgfldlwjvjvtlyhxaiqt.supabase.co
SUPABASE_DB_PORT=5432
SUPABASE_DB_NAME=postgres
SUPABASE_DB_USER=postgres.pgfldlwjvjvtlyhxaiqt
SUPABASE_DB_PASSWORD=YOUR_ACTUAL_PASSWORD_HERE
```

### Step 4: Run with Updated Credentials
```powershell
# Load environment variables
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        Set-Item -Path "env:$($matches[1])" -Value $matches[2]
    }
}

# Run the application
mvn spring-boot:run
```

### Step 5: Check Network Connectivity
If still failing, test direct connection:
```powershell
Test-NetConnection -ComputerName db.pgfldlwjvjvtlyhxaiqt.supabase.co -Port 5432
```

If this fails:
- Check firewall settings
- Try from a different network
- Contact your network administrator
- Consider using VPN if required

---

## Option 2: Use H2 In-Memory Database (Local Development) ✅ RECOMMENDED

This is the **easiest option** for local development and testing.

### Advantages
- ✅ No external dependencies
- ✅ Fast setup
- ✅ No network issues
- ✅ Pre-loaded with sample data
- ✅ Works offline

### How to Use
```powershell
.\start-local.ps1
```

Or manually:
```powershell
$env:SPRING_PROFILES_ACTIVE='local'
mvn spring-boot:run
```

### Access Points
- Application: http://localhost:8080
- H2 Console: http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:fashionretaildb`
  - Username: `sa`
  - Password: `password`

### Sample Data Included
- 6 Products (watches, shoes, t-shirts, track pants)
- 1 Test User: `test@example.com` / `password123`

---

## Option 3: Use Production Profile

If you want to test Supabase connection with optimized settings:

```powershell
$env:SPRING_PROFILES_ACTIVE='prod'
$env:SUPABASE_DB_PASSWORD='YOUR_ACTUAL_PASSWORD'
mvn spring-boot:run
```

This uses `application-prod.properties` with:
- Direct database connection (not pooler)
- Shorter timeouts (30s instead of 60s)
- Enhanced connection pooling
- PostgreSQL-specific optimizations

---

## Common Issues and Solutions

### Issue 1: SocketTimeoutException
**Error**: `java.net.SocketTimeoutException: Connect timed out`

**Causes**:
- Firewall blocking port 5432
- Database is paused
- Network restrictions
- VPN required

**Solutions**:
1. Resume database in Supabase dashboard
2. Check firewall settings
3. Try different network
4. Use H2 for local development

### Issue 2: Authentication Failed
**Error**: `PSQLException: FATAL: password authentication failed`

**Solution**:
1. Reset password in Supabase dashboard
2. Update `SUPABASE_DB_PASSWORD` environment variable
3. Ensure no extra spaces in password

### Issue 3: Database Not Found
**Error**: `FATAL: database "postgres" does not exist`

**Solution**:
- Verify database name in Supabase dashboard
- Update `SUPABASE_DB_NAME` if different

### Issue 4: SSL Required
**Error**: `FATAL: no pg_hba.conf entry`

**Solution**:
- Ensure `sslmode=require` is in connection URL
- Our current configuration already includes this

---

## Comparison: H2 vs Supabase

| Feature | H2 (Local) | Supabase (Production) |
|---------|------------|----------------------|
| Setup Time | ⚡ Instant | ⏱️ Requires configuration |
| Network Required | ❌ No | ✅ Yes |
| Persistent Data | ❌ No (in-memory) | ✅ Yes |
| Performance | 🚀 Very Fast | 🐢 Network dependent |
| Use Case | Development/Testing | Production/Sharing |
| Sample Data | ✅ Pre-loaded | ❌ Must import |

---

## Recommended Workflow

1. **Local Development**: Use H2 (fastest, no setup)
   ```powershell
   .\start-local.ps1
   ```

2. **Testing Supabase**: Once in a while, test production config
   ```powershell
   $env:SPRING_PROFILES_ACTIVE='prod'
   mvn spring-boot:run
   ```

3. **Production Deployment**: Use Supabase with proper credentials
   ```bash
   export SPRING_PROFILES_ACTIVE=prod
   export SUPABASE_DB_PASSWORD=xxxxx
   java -jar target/fashion-retail-app.jar
   ```

---

## Configuration Files Reference

### application.properties (Default)
- Uses Supabase with direct connection
- Environment variables for credentials
- Optimized Hikari pool settings

### application-local.properties
- H2 in-memory database
- Sample data pre-loaded
- H2 console enabled

### application-prod.properties
- Production-ready Supabase config
- Enhanced connection pooling
- PostgreSQL-specific optimizations

---

## Need Help?

1. Run diagnostics: `.\test-supabase-connection.ps1`
2. Check Supabase dashboard: https://supabase.com/dashboard
3. Review logs: Look for connection errors in console output
4. Use H2 if stuck: `.\start-local.ps1`

---

## Summary

**For Local Development**: Just use H2!
```powershell
.\start-local.ps1
```
Done! ✅

**For Production**: Fix Supabase credentials and test connectivity first.
