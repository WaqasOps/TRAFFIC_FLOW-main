# CI/CD Pipeline Setup Checklist

## ✅ What Was Fixed

### Pipeline Issues Resolved:
- ✅ Added database environment variables (DB_USER, DB_HOST, DB_NAME, DB_PASS, DB_PORT)
- ✅ Frontend now receives REACT_APP_* variables at build time
- ✅ Service-to-service URLs properly configured
- ✅ All environment configuration from GitHub secrets
- ✅ Zero hardcoded values in pipeline

### Application Code Compatibility:
- ✅ Services A, B, C, D, E all require database configuration
- ✅ Frontend requires build-time environment variables for React
- ✅ Service chain: A→B→C→D→E
- ✅ Health check endpoints available on `/health`

---

## 🔧 Required GitHub Secrets (26 Total)

### Group 1: AWS Configuration (4 secrets)
```
1. AWS_ACCOUNT_ID           → 12-digit AWS account ID
2. AWS_ACCESS_KEY_ID        → AWS IAM user access key
3. AWS_SECRET_ACCESS_KEY    → AWS IAM user secret key
4. AWS_REGION               → ap-south-1 (or your region)
```

### Group 2: EC2 Connection (3 secrets)
```
5. EC2_HOST                 → Your EC2 public IP or domain
6. EC2_USER                 → ubuntu (typically)
7. EC2_SSH_KEY              → Full .pem file content
```

### Group 3: Database Configuration (5 secrets) ⚠️ CRITICAL
```
8. DB_USER                  → postgres (or your DB user)
9. DB_HOST                  → RDS endpoint or IP
10. DB_NAME                 → traffic_flow (or your DB name)
11. DB_PASS                 → Secure password
12. DB_PORT                 → 5432 (PostgreSQL default)
```

### Group 4: Application Configuration (2 secrets)
```
13. NODE_ENV                → production
14. DOCKER_NETWORK          → traffic-flow
```

### Group 5: Service Ports (5 secrets)
```
15. FRONTEND_PORT           → 80
16. SERVICE_A_PORT          → 3001
17. SERVICE_B_PORT          → 3002
18. SERVICE_C_PORT          → 3003
19. SERVICE_D_PORT          → 3004
20. SERVICE_E_PORT          → 3005
```

### Group 6: Container Names (6 secrets)
```
21. CONTAINER_FRONTEND      → traffic-flow-frontend
22. CONTAINER_SERVICE_A     → traffic-flow-service-a
23. CONTAINER_SERVICE_B     → traffic-flow-service-b
24. CONTAINER_SERVICE_C     → traffic-flow-service-c
25. CONTAINER_SERVICE_D     → traffic-flow-service-d
26. CONTAINER_SERVICE_E     → traffic-flow-service-e
```

### Group 7: Frontend URLs (11 secrets - REACT_APP_ variables)
These are baked into the Frontend Docker image during build:
```
REACT_APP_SERVICE_A_URL         → http://EC2_IP:3001/serviceA
REACT_APP_SERVICE_B_URL         → http://EC2_IP:3002/serviceB
REACT_APP_SERVICE_C_URL         → http://EC2_IP:3003/serviceC
REACT_APP_SERVICE_D_URL         → http://EC2_IP:3004/serviceD
REACT_APP_SERVICE_E_URL         → http://EC2_IP:3005/serviceE

REACT_APP_SERVICE_A_HEALTH      → http://EC2_IP:3001/health
REACT_APP_SERVICE_B_HEALTH      → http://EC2_IP:3002/health
REACT_APP_SERVICE_C_HEALTH      → http://EC2_IP:3003/health
REACT_APP_SERVICE_D_HEALTH      → http://EC2_IP:3004/health
REACT_APP_SERVICE_E_HEALTH      → http://EC2_IP:3005/health

REACT_APP_REQUEST_TIMEOUT       → 15000 (milliseconds)
REACT_APP_ENABLE_DEBUG          → false (production) or true (dev)
```

---

## 📋 Step-by-Step Setup

### Step 1: AWS Setup
```bash
# 1. Create IAM User
aws iam create-user --user-name traffic-flow-cicd

# 2. Create Access Keys
aws iam create-access-key --user-name traffic-flow-cicd

# 3. Attach ECR permissions policy
# Attach policy: `AmazonEC2ContainerRegistryFullAccess`

# 4. Get Account ID
aws sts get-caller-identity
```

### Step 2: EC2 Setup
```bash
# 1. Create/Get EC2 instance
# - OS: Ubuntu 20.04 or later
# - Get public IP from AWS console
# - Download .pem file

# 2. Test SSH access
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# 3. Install Docker and AWS CLI on EC2
sudo apt-get update
sudo apt-get install -y docker.io awscli
sudo usermod -aG docker ubuntu
```

### Step 3: Database Setup
```bash
# Option A: AWS RDS
# 1. Create PostgreSQL RDS instance
# 2. Note the endpoint (DB_HOST)
# 3. Create database: traffic_flow
# 4. Create user: postgres with password

# Option B: Self-hosted on EC2
sudo apt-get install -y postgresql postgresql-contrib
sudo -u postgres psql
# CREATE DATABASE traffic_flow;
# CREATE USER postgres WITH PASSWORD 'your_password';
# GRANT ALL PRIVILEGES ON DATABASE traffic_flow TO postgres;
```

### Step 4: GitHub Secrets Setup
```
1. Go to: GitHub → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret from the list above
4. Example:
   Name: AWS_ACCOUNT_ID
   Value: 123456789012
5. Repeat for all 26+ secrets
```

### Step 5: Verify Before Deployment
```bash
# 1. Test EC2 SSH connection
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# 2. Test Docker on EC2
docker --version

# 3. Test database access
psql -h DB_HOST -U DB_USER -d DB_NAME -c "SELECT NOW();"
```

### Step 6: Deploy
```bash
# 1. Push code to 'dev' branch (or adjust workflow trigger)
git push origin dev

# 2. GitHub Actions starts automatically
# 3. Monitor: GitHub → Actions tab
# 4. All 6 services build in parallel
# 5. Then deploy to EC2 in order

# View logs:
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
docker logs traffic-flow-service-a  # Example
```

---

## 🧪 Testing After Deployment

### Check Running Containers
```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
docker ps --filter "name=traffic-flow"
```

### Test Service Chain
```bash
# From EC2 or locally with curl
curl http://YOUR_EC2_IP/serviceA  # Should go through all 5 services

# Check Service A logs
docker logs traffic-flow-service-a -f
```

### Check Frontend
```bash
# Open in browser
http://YOUR_EC2_IP
# Should see React frontend with all service health indicators
```

### Test Health Endpoints
```bash
curl http://YOUR_EC2_IP:3001/health   # Service A
curl http://YOUR_EC2_IP:3002/health   # Service B
curl http://YOUR_EC2_IP:3003/health   # Service C
curl http://YOUR_EC2_IP:3004/health   # Service D
curl http://YOUR_EC2_IP:3005/health   # Service E
```

---

## 🚨 Critical Issues & Fixes

### Issue 1: Services Won't Start
**Symptom**: Container exits immediately
**Cause**: Missing database variables
**Fix**: Ensure all DB_* secrets are set and database is accessible

### Issue 2: Frontend Shows "Cannot Reach Services"
**Symptom**: Frontend loads but shows red service status
**Cause**: REACT_APP_SERVICE_*_URL variables incorrect or services not accessible
**Fix**: Verify EC2 IP and ports are correct in REACT_APP_* secrets

### Issue 3: Database Connection Error
**Symptom**: Services log `ECONNREFUSED` or `ENOTFOUND`
**Cause**: Database host unreachable or credentials wrong
**Fix**: Test database connection from EC2 manually

### Issue 4: ECR Push Fails
**Symptom**: "Access Denied" or "Unauthorized"
**Cause**: AWS credentials invalid or permissions missing
**Fix**: Verify AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are correct

---

## 📊 Environment Variables Map

```
GitHub Secrets
        ↓
├── Build Time (stored in Docker image)
│   ├── Frontend: REACT_APP_* variables
│   └── Baked into: /app/.env.local
│
└── Runtime (passed via docker run -e)
    ├── All services: PORT, NODE_ENV
    ├── All services: DB_*, SERVICE_*_URL
    └── Container names: From CONTAINER_* secrets
```

---

## 🔐 Security Checklist

- [ ] Database user has no unnecessary privileges
- [ ] SSH key is 4096-bit RSA
- [ ] SSH public key in EC2 ~/.ssh/authorized_keys
- [ ] Database restricted to EC2 security group only
- [ ] No secrets committed to repository
- [ ] Use IAM user cre credentials (not root AWS account)
- [ ] Rotate credentials monthly
- [ ] Enable MFA on AWS account

---

## 📞 Support

For issues, check:
1. `GITHUB_SECRETS.md` - Detailed secret documentation
2. GitHub Actions workflow logs
3. EC2 container logs: `docker logs <container-name>`
4. Database connection: `psql -h DB_HOST -U DB_USER`

All environment variables are controlled via GitHub secrets - no hardcoding in the codebase!
