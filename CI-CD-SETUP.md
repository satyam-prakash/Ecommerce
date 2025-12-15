# Automated CI/CD Deployment to EC2

🚀 **Your application now deploys automatically to EC2 when you push code to GitHub!**

## How It Works

```
Code Change → Git Push → GitHub Actions → Build → Test → Deploy to EC2 → Live! 🎉
```

Every time you push to `main` or `master` branch:
1. ✅ Code is checked out
2. ✅ Java 21 is set up
3. ✅ Maven builds the application
4. ✅ Tests run automatically
5. ✅ JAR is uploaded to EC2
6. ✅ Application restarts on EC2
7. ✅ Health check confirms it's running

**Total time:** ~3-5 minutes from push to live!

---

## Setup Instructions (One-Time Only)

### Step 1: Push Your Code to GitHub

If you haven't already:

```powershell
# Initialize git (if not done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit with CI/CD"

# Create GitHub repository and push
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git branch -M main
git push -u origin main
```

### Step 2: Configure GitHub Secrets

Go to your GitHub repository:
1. Click **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add these secrets:

#### Required Secrets:

| Secret Name | Value | Where to Get It |
|-------------|-------|-----------------|
| `EC2_HOST` | Your EC2 public IP | AWS EC2 Console → Instances → Public IPv4 |
| `EC2_USER` | `ec2-user` | Default for Amazon Linux |
| `SSH_PRIVATE_KEY` | Your .pem file content | Open your .pem file, copy ALL content |

#### Optional Secrets (for AWS CLI features):

| Secret Name | Value | Where to Get It |
|-------------|-------|-----------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | AWS IAM Console |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | AWS IAM Console |

---

## How to Add SSH_PRIVATE_KEY Secret

### Option 1: Copy from PEM file (Windows)

```powershell
# View your PEM file content
Get-Content "C:\path\to\your-key.pem" | clip
```

Now paste into GitHub secret (it's already in clipboard)!

### Option 2: Manual Copy

1. Open your `.pem` file in Notepad
2. Copy **EVERYTHING** including:
   ```
   -----BEGIN RSA PRIVATE KEY-----
   (all the content)
   -----END RSA PRIVATE KEY-----
   ```
3. Paste into GitHub secret

⚠️ **Important:** Make sure there are no extra spaces or newlines at the start/end!

---

## Step 3: Enable GitHub Actions

1. Go to your repository on GitHub
2. Click **Actions** tab
3. If prompted, click **I understand my workflows, go ahead and enable them**

---

## Step 4: Test Automated Deployment

Make a simple change and push:

```powershell
# Make a small change
echo "# Test CI/CD" >> README.md

# Commit and push
git add .
git commit -m "Test automated deployment"
git push
```

Then:
1. Go to GitHub → **Actions** tab
2. Watch the deployment progress live!
3. When complete, visit `http://YOUR_EC2_IP` to see changes

---

## Workflow Features

### ✅ Automatic Triggers

- **On Push:** Deploys when you push to main/master
- **Manual Trigger:** Can also run manually from GitHub Actions tab

### ✅ Safety Features

- **Backup:** Previous version is backed up before deployment
- **Health Check:** Verifies application starts successfully
- **Rollback:** If deployment fails, keeps previous version running

### ✅ Build Features

- **Java 21:** Uses Amazon Corretto 21
- **Maven Cache:** Speeds up builds
- **Test Execution:** Runs all tests before deploying
- **Continue on Test Failure:** Tests failures don't block deployment (optional)

---

## View Deployment Status

### In GitHub

1. Go to your repository
2. Click **Actions** tab
3. See all deployments with status (✅ Success / ❌ Failed)
4. Click any deployment to see detailed logs

### Build Status Badge

Add this to your README.md:

```markdown
![Deploy Status](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/deploy-ec2.yml/badge.svg)
```

---

## Manual Deployment Trigger

Sometimes you want to deploy without pushing code:

1. Go to GitHub → **Actions** tab
2. Select **Deploy to EC2** workflow
3. Click **Run workflow** dropdown
4. Click **Run workflow** button
5. Watch it deploy!

---

## Troubleshooting

### ❌ Deployment Failed

**Check the logs:**
1. GitHub → Actions → Click the failed run
2. Expand failed step to see error

**Common Issues:**

#### SSH Connection Failed
- **Cause:** Wrong EC2_HOST or SSH_PRIVATE_KEY
- **Fix:** Double-check secrets in GitHub Settings

#### Permission Denied
- **Cause:** SSH key doesn't match EC2 instance
- **Fix:** Ensure SSH_PRIVATE_KEY matches the key pair used when creating EC2

#### Application Won't Start
- **Cause:** Supabase database paused or connection failed
- **Fix:** 
  1. Resume Supabase database
  2. SSH to EC2: `ssh -i your-key.pem ec2-user@YOUR_EC2_IP`
  3. Check logs: `sudo journalctl -u fashion-retail -f`

#### Build Failed
- **Cause:** Compilation errors or test failures
- **Fix:** Run `mvn clean test` locally first to catch errors

---

## Deployment Workflow Details

### What Happens During Deployment

```
1. 🔄 GitHub detects push
2. 🏗️  Spins up Ubuntu runner
3. ☕ Installs Java 21
4. 📦 Runs mvn clean package
5. 🧪 Runs mvn test
6. 🔐 Sets up SSH connection
7. 📤 Uploads JAR to EC2
8. 🛑 Stops old application
9. 💾 Backs up previous version
10. 📥 Installs new version
11. ▶️  Starts application
12. ⏱️  Waits 15 seconds
13. 🏥 Health check
14. ✅ Deployment complete!
```

**Average time:** 3-5 minutes

---

## Environment Variables on EC2

The systemd service file has your Supabase credentials:

```bash
# To update environment variables on EC2:
ssh -i your-key.pem ec2-user@YOUR_EC2_IP

sudo nano /etc/systemd/system/fashion-retail.service

# Update Environment variables
# Then:
sudo systemctl daemon-reload
sudo systemctl restart fashion-retail
```

---

## Advanced: Deploy to Multiple Environments

Create separate workflows for staging and production:

### `.github/workflows/deploy-staging.yml`
```yaml
on:
  push:
    branches:
      - develop
```

### `.github/workflows/deploy-production.yml`
```yaml
on:
  push:
    branches:
      - main
```

Add separate secrets: `STAGING_EC2_HOST`, `PROD_EC2_HOST`, etc.

---

## Rollback to Previous Version

If deployment breaks something:

```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@YOUR_EC2_IP

# List backups
ls -lh /opt/fashion-retail/*.backup.*

# Restore previous version (find the most recent backup)
sudo systemctl stop fashion-retail
sudo cp /opt/fashion-retail/fashion-retail-app.jar.backup.20251215-143022 \
       /opt/fashion-retail/fashion-retail-app.jar
sudo systemctl start fashion-retail
```

---

## Monitoring Deployments

### GitHub Actions Logs
- Real-time deployment progress
- Build output and test results
- Deployment status and errors

### EC2 Application Logs
```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@YOUR_EC2_IP

# View real-time logs
sudo journalctl -u fashion-retail -f

# View last 100 lines
sudo journalctl -u fashion-retail -n 100
```

### Application Health
- Health endpoint: `http://YOUR_EC2_IP/actuator/health`
- GitHub Actions checks this automatically

---

## Cost Optimization

### GitHub Actions Free Tier
- **2,000 minutes/month** for private repos (FREE)
- **Unlimited** for public repos (FREE)
- Each deployment uses ~5 minutes

**You can do ~400 deployments/month for free!**

### Tips to Reduce Usage
1. Don't trigger on every commit (use pull requests)
2. Skip tests with `-DskipTests` in workflow
3. Cache Maven dependencies (already configured)

---

## Security Best Practices

✅ **Never commit secrets** to repository
✅ **Use GitHub Secrets** for all sensitive data
✅ **Limit SSH key** to only EC2 deployment
✅ **Rotate keys** regularly
✅ **Review Actions logs** before making them public
✅ **Use branch protection** to prevent accidental deployments

---

## Quick Commands Reference

### Local Development
```powershell
# Build locally
mvn clean package

# Run locally with H2
$env:SPRING_PROFILES_ACTIVE="local"
mvn spring-boot:run
```

### Manual Deployment (Override CI/CD)
```powershell
# Deploy manually if needed
.\deploy-to-ec2.ps1 -EC2Host "YOUR_EC2_IP" -SSHKey "C:\path\to\key.pem"
```

### Check EC2 Status
```bash
ssh -i your-key.pem ec2-user@YOUR_EC2_IP
sudo systemctl status fashion-retail
sudo journalctl -u fashion-retail -f
```

---

## Typical Development Workflow

### Daily Development
```powershell
# 1. Make changes locally
# 2. Test with H2 database
$env:SPRING_PROFILES_ACTIVE="local"
mvn spring-boot:run

# 3. Commit changes
git add .
git commit -m "Add new feature"

# 4. Push to GitHub (triggers deployment)
git push

# 5. Watch deployment in GitHub Actions
# 6. Verify on EC2: http://YOUR_EC2_IP
```

**That's it!** No manual deployment needed! 🎉

---

## Next Steps

1. ✅ Set up GitHub secrets (5 minutes)
2. ✅ Push code to GitHub
3. ✅ Watch first automated deployment
4. ✅ Make a change and push again
5. ✅ See it deploy automatically!

---

## Support

**Deployment failing?**
1. Check GitHub Actions logs
2. Verify GitHub secrets are correct
3. SSH to EC2 and check application logs
4. See [EC2-DEPLOYMENT-GUIDE.md](EC2-DEPLOYMENT-GUIDE.md) for troubleshooting

---

## Summary

**Before CI/CD:**
```
Code → Build → Upload → SSH → Deploy → Test
Time: 10-15 minutes of manual work
```

**After CI/CD:**
```
Code → Git Push → ☕ (wait 5 min) → ✅ LIVE!
Time: 5 minutes automated
```

**Zero manual steps!** Just code and push! 🚀

---

**Your application now has professional-grade CI/CD! 🎊**

Every push deploys automatically. Focus on coding, not deploying!
