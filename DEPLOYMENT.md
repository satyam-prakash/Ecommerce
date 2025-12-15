# Fashion Retail E-Commerce - Deployment Guide

## ✅ Java 21 LTS Upgrade Complete!
Your project has been successfully upgraded from Java 17 to Java 21 LTS.

---

## 🚀 Local Deployment Options

### Option 1: Run with H2 In-Memory Database (Recommended for Testing)

**Start the application:**
```powershell
$env:JAVA_HOME="C:\Users\praka\.jdk\jdk-21.0.8"
$env:PATH="C:\Users\praka\.jdk\jdk-21.0.8\bin;$env:PATH"
$env:SPRING_PROFILES_ACTIVE="local"
mvn spring-boot:run
```

**Access:**
- Application: http://localhost:8080
- H2 Console: http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:fashionretaildb`
  - Username: `sa`
  - Password: (leave blank)

**Test Credentials:**
- Email: test@example.com
- Password: password123

---

### Option 2: Run with Supabase PostgreSQL

**Prerequisites:**
1. Ensure Supabase database is active (not paused)
2. Verify database credentials in `.env` file

**Start the application:**
```powershell
$env:JAVA_HOME="C:\Users\praka\.jdk\jdk-21.0.8"
$env:PATH="C:\Users\praka\.jdk\jdk-21.0.8\bin;$env:PATH"
$env:SUPABASE_DB_HOST="db.pgfldlwjvjvtlyhxaiqt.supabase.co"
$env:SUPABASE_DB_PORT="5432"
$env:SUPABASE_DB_NAME="postgres"
$env:SUPABASE_DB_USER="postgres"
$env:SUPABASE_DB_PASSWORD="YOUR-PASSWORD-HERE"
mvn spring-boot:run
```

---

### Option 3: Run as JAR File

**Build the JAR:**
```powershell
$env:JAVA_HOME="C:\Users\praka\.jdk\jdk-21.0.8"
$env:PATH="C:\Users\praka\.jdk\jdk-21.0.8\bin;$env:PATH"
mvn clean package
```

**Run the JAR (with H2):**
```powershell
$env:SPRING_PROFILES_ACTIVE="local"
java -jar target/fashion-retail-app.jar
```

**Run the JAR (with Supabase):**
```powershell
java -jar target/fashion-retail-app.jar `
  --spring.datasource.url=jdbc:postgresql://db.pgfldlwjvjvtlyhxaiqt.supabase.co:5432/postgres `
  --spring.datasource.username=postgres `
  --spring.datasource.password=YOUR-PASSWORD
```

---

## 🐳 Docker Deployment

### Build Docker Image

**Update Dockerfile for Java 21:**
```dockerfile
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY target/fashion-retail-app.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Build and run:**
```powershell
# Build JAR first
mvn clean package

# Build Docker image
docker build -t fashion-retail-app .

# Run with H2 (local testing)
docker run -p 8080:8080 -e SPRING_PROFILES_ACTIVE=local fashion-retail-app

# Run with Supabase
docker run -p 8080:8080 `
  -e SUPABASE_DB_HOST=db.pgfldlwjvjvtlyhxaiqt.supabase.co `
  -e SUPABASE_DB_PORT=5432 `
  -e SUPABASE_DB_NAME=postgres `
  -e SUPABASE_DB_USER=postgres `
  -e SUPABASE_DB_PASSWORD=YOUR-PASSWORD `
  fashion-retail-app
```

**Or use Docker Compose:**
```powershell
# Update .env file with your credentials first
docker-compose up --build
```

---

## ☁️ Cloud Deployment Options

### 1. AWS EC2 Deployment

**Use provided script:**
```bash
chmod +x scripts/ec2-setup.sh scripts/deploy.sh
./scripts/ec2-setup.sh
./scripts/deploy.sh
```

**Manual steps:**
1. Launch EC2 instance (Amazon Linux 2 or Ubuntu)
2. Install Java 21:
   ```bash
   sudo yum install -y java-21-amazon-corretto
   # or for Ubuntu
   sudo apt install openjdk-21-jdk
   ```
3. Upload JAR file
4. Run: `java -jar fashion-retail-app.jar`

### 2. Heroku Deployment

**Prerequisites:**
- Install Heroku CLI
- Have Heroku account

**Steps:**
```bash
# Login to Heroku
heroku login

# Create app
heroku create fashion-retail-app

# Set Java version
echo "java.runtime.version=21" > system.properties

# Add Procfile
echo "web: java -jar target/fashion-retail-app.jar" > Procfile

# Set environment variables
heroku config:set SPRING_PROFILES_ACTIVE=local

# Deploy
git add .
git commit -m "Deploy to Heroku"
git push heroku main
```

### 3. Azure App Service

**Using Azure CLI:**
```bash
# Login
az login

# Create resource group
az group create --name fashion-retail-rg --location eastus

# Create App Service plan
az appservice plan create --name fashion-retail-plan --resource-group fashion-retail-rg --sku B1 --is-linux

# Create web app
az webapp create --resource-group fashion-retail-rg --plan fashion-retail-plan --name fashion-retail-app --runtime "JAVA:21-java21"

# Deploy JAR
az webapp deploy --resource-group fashion-retail-rg --name fashion-retail-app --src-path target/fashion-retail-app.jar --type jar
```

### 4. GitHub Actions CI/CD

Your project has a CI/CD workflow at `.github/workflows/ci-cd.yml`. 

**To enable:**
1. Push code to GitHub
2. Add secrets in GitHub repository settings:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `SUPABASE_DB_PASSWORD`
3. Push changes to trigger deployment

---

## 📊 Monitoring & Health Checks

**Health check endpoint:**
```
http://localhost:8080/actuator/health
```

**Available actuator endpoints:**
- `/actuator/health` - Application health status
- `/actuator/info` - Application information
- `/actuator/metrics` - Application metrics

---

## 🔧 Troubleshooting

### Database Connection Issues

**If Supabase connection fails:**
1. Check if database is paused: https://supabase.com/dashboard/project/pgfldlwjvjvtlyhxaiqt
2. Verify credentials in Supabase dashboard
3. Test connection:
   ```powershell
   Test-NetConnection -ComputerName db.pgfldlwjvjvtlyhxaiqt.supabase.co -Port 5432
   ```
4. Use H2 profile for local testing instead

### Application Won't Start

**Check Java version:**
```powershell
java -version  # Should show 21.0.8
```

**Check port 8080:**
```powershell
netstat -ano | findstr :8080
```

**View logs with debug:**
```powershell
mvn spring-boot:run -Dspring-boot.run.arguments=--debug
```

---

## 📝 Quick Reference

**Start locally (H2):**
```powershell
$env:JAVA_HOME="C:\Users\praka\.jdk\jdk-21.0.8"; $env:SPRING_PROFILES_ACTIVE="local"; mvn spring-boot:run
```

**Build JAR:**
```powershell
$env:JAVA_HOME="C:\Users\praka\.jdk\jdk-21.0.8"; mvn clean package
```

**Run JAR:**
```powershell
java -jar target/fashion-retail-app.jar --spring.profiles.active=local
```

---

## 🎯 What's Next?

1. ✅ Java 21 LTS upgrade - **COMPLETE**
2. ⏳ Fix Supabase connection or use H2 for testing
3. ⏳ Build Docker image
4. ⏳ Deploy to cloud platform (AWS/Azure/Heroku)
5. ⏳ Set up CI/CD pipeline

**Need help?** Check the logs or test with H2 database first!
