# GitHub Secrets Configuration

This document outlines all the required GitHub secrets for the CI/CD pipeline to work correctly.

## How to Add Secrets to GitHub

1. Navigate to your GitHub repository
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Enter the secret name and value
5. Click **Add secret**

---

## Required Secrets

### AWS Configuration

#### `AWS_ACCOUNT_ID`
- **Description**: Your AWS Account ID (12-digit number)
- **Example**: `123456789012`
- **Where to get**: AWS Console → Account dropdown → Copy Account ID

#### `AWS_ACCESS_KEY_ID`
- **Description**: AWS IAM Access Key ID
- **Where to get**: AWS Console → IAM → Users → Security credentials → Create access key
- **Permissions needed**: ECR push/pull, EC2 describe (see IAM Policy below)

#### `AWS_SECRET_ACCESS_KEY`
- **Description**: AWS IAM Secret Access Key
- **Where to get**: Generated along with Access Key ID
- **⚠️ Important**: Never commit this to version control

#### `AWS_REGION`
- **Description**: AWS region for ECR and EC2
- **Example**: `ap-south-1`, `us-east-1`, `eu-west-1`
- **Where to get**: Specify your desired region

---

### EC2 Configuration

#### `EC2_HOST`
- **Description**: EC2 instance public IP address or domain name
- **Example**: `54.123.45.67` or `ec2.example.com`
- **Where to get**: AWS Console → EC2 → Instances → Copy Public IPv4 address

#### `EC2_USER`
- **Description**: SSH username for EC2 instance
- **Example**: `ubuntu`
- **Note**: Make sure this user has sudo privileges

#### `EC2_SSH_KEY`
- **Description**: Private SSH key for EC2 authentication (full PEM content)
- **Format**: Multi-line PEM format
- **Example**:
  ```
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEA7vJ3...
  ...
  -----END RSA PRIVATE KEY-----
  ```
- **Where to get**: Use the `.pem` file generated when creating EC2 key pair

---

### Environment Configuration

#### `NODE_ENV`
- **Description**: Application environment mode
- **Example**: `production`
- **Options**: `production`, `staging`, `development`

#### `DOCKER_NETWORK`
- **Description**: Docker network name for internal service communication
- **Example**: `traffic-flow`
- **Default suggested**: `traffic-flow`

---

### Database Configuration (CRITICAL)

⚠️ **All backend services require database access. Services will fail without these.**

#### `DB_USER`
- **Description**: PostgreSQL username
- **Example**: `postgres`
- **Required for**: Service A, B, C, D, E

#### `DB_HOST`
- **Description**: Database host address (RDS endpoint or IP)
- **Example**: `mydb-instance.rds.amazonaws.com` or `10.0.1.50`
- **Required for**: All services
- **Note**: Must be accessible from EC2 instance

#### `DB_NAME`
- **Description**: Database name
- **Example**: `traffic_flow`
- **Required for**: All services

#### `DB_PASS`
- **Description**: Database password
- **Example**: `securePassword123!`
- **Required for**: All services
- **⚠️ Important**: Never commit to repository

#### `DB_PORT`
- **Description**: Database port
- **Example**: `5432`
- **Default**: 5432 for PostgreSQL

---

### Frontend React Build Environment Variables

These variables are baked into the Docker image during build (not runtime).

#### `REACT_APP_SERVICE_A_URL`
- **Description**: Frontend URL to Service A endpoint
- **Example**: `http://54.123.45.67:3001/serviceA`
- **Note**: Use actual EC2 IP or domain name for production

#### `REACT_APP_SERVICE_B_URL`, `REACT_APP_SERVICE_C_URL`, `REACT_APP_SERVICE_D_URL`, `REACT_APP_SERVICE_E_URL`
- **Description**: Frontend URLs to other service endpoints
- **Format**: `http://ec2-ip:port/service<X>`

#### `REACT_APP_SERVICE_A_HEALTH`, `REACT_APP_SERVICE_B_HEALTH`, etc
- **Description**: Health check endpoint URLs for each service
- **Example**: `http://54.123.45.67:3001/health`

#### `REACT_APP_REQUEST_TIMEOUT`
- **Description**: Request timeout in milliseconds
- **Example**: `15000`
- **Default**: 15000 (15 seconds)

#### `REACT_APP_ENABLE_DEBUG`
- **Description**: Enable debug mode for console logging
- **Example**: `false` (production) or `true` (development)

---

### Service Port Configuration

#### `FRONTEND_PORT`
- **Description**: Port for frontend service on host
- **Example**: `80` (or `8080` if using reverse proxy)

#### `SERVICE_A_PORT`
- **Description**: Port for Service A on host
- **Example**: `3001`

#### `SERVICE_B_PORT`
- **Description**: Port for Service B on host
- **Example**: `3002`

#### `SERVICE_C_PORT`
- **Description**: Port for Service C on host
- **Example**: `3003`

#### `SERVICE_D_PORT`
- **Description**: Port for Service D on host
- **Example**: `3004`

#### `SERVICE_E_PORT`
- **Description**: Port for Service E on host
- **Example**: `3005`

---

### Container Names Configuration

#### `CONTAINER_FRONTEND`
- **Description**: Docker container name for frontend
- **Example**: `traffic-flow-frontend`

#### `CONTAINER_SERVICE_A`
- **Description**: Docker container name for Service A
- **Example**: `traffic-flow-service-a`

#### `CONTAINER_SERVICE_B`
- **Description**: Docker container name for Service B
- **Example**: `traffic-flow-service-b`

#### `CONTAINER_SERVICE_C`
- **Description**: Docker container name for Service C
- **Example**: `traffic-flow-service-c`

#### `CONTAINER_SERVICE_D`
- **Description**: Docker container name for Service D
- **Example**: `traffic-flow-service-d`

#### `CONTAINER_SERVICE_E`
- **Description**: Docker container name for Service E
- **Example**: `traffic-flow-service-e`

---

## IAM Policy for CI/CD

Create an IAM user with the following policy for GitHub Actions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:CreateRepository",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:DescribeRepositories",
        "ecr:ListImages"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Deployment Overview

For each service (Frontend, Service A-E), the workflow automatically:

1. **Builds** Docker image from the service's Dockerfile
2. **Pushes** to ECR with both `<commit-sha>` and `latest` tags
3. **Deploys** via individual `docker run` commands on EC2 with environment variables passed from GitHub secrets

### ECR Repository Naming Convention

The workflow automatically creates repositories with these names:
- `traffic-flow-frontend`
- `traffic-flow-service-a`
- `traffic-flow-service-b`
- `traffic-flow-service-c`
- `traffic-flow-service-d`
- `traffic-flow-service-e`

If repositories don't exist, the IAM policy above allows automatic creation.

### Environment Variables

All environment variables are passed directly to `docker run` commands via GitHub secrets:
- `PORT`: Service port number
- `NODE_ENV`: Set to `production` automatically
- Service-to-service URLs (e.g., `SERVICE_B_URL`): Automatically set using Docker DNS names

To add custom environment variables:
1. Add them as GitHub secrets (e.g., `SECRET_API_KEY`)
2. Reference them in the `.github/workflows/deploy.yml` workflow with `${{ secrets.SECRET_API_KEY }}`
3. Pass them to the `docker run -e` flags

---

## EC2 Instance Prerequisites

Your EC2 instance should have:

1. **Docker** installed
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker.io
   sudo usermod -aG docker $USER
   ```

2. **AWS CLI** installed
   ```bash
   sudo apt-get install -y awscli
   ```

3. **SSH access** configured for GitHub Actions

---

## Testing the Secrets

Before deploying, verify your secrets:

1. **SSH to EC2**:
   ```bash
   ssh -i /path/to/key.pem ubuntu@<EC2_HOST>
   ```

2. **Test ECR login locally**:
   ```bash
   export AWS_ACCESS_KEY_ID=<your-key>
   export AWS_SECRET_ACCESS_KEY=<your-secret>
   aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com
   ```

3. **Verify docker is running**:
   ```bash
   docker --version
   ```

---

## Troubleshooting

### "Access Denied" Error in GitHub Actions
- Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are correct
- Check IAM user has ECR permissions (see policy above)

### "Could not connect to EC2" Error
- Verify `EC2_HOST` is publicly accessible
- Check `EC2_SSH_KEY` contains full PEM content (including `-----BEGIN` and `-----END` lines)
- Ensure security group allows SSH (port 22) from GitHub Actions runners

### "docker: command not found" on EC2
- Install Docker: `sudo apt-get install -y docker.io`
- Add user to docker group: `sudo usermod -aG docker ubuntu`

---

## Security Best Practices

✅ **DO:**
- Use a dedicated IAM user for CI/CD (not root account)
- Rotate access keys regularly
- Use SSM Parameter Store for non-critical configuration
- Enable MFA on AWS account

❌ **DON'T:**
- Commit secrets to repository
- Use the same credentials across multiple projects
- Store secrets in plain text anywhere
- Use overly permissive IAM policies

## Deployment Workflow Overview

```
GitHub Push
    ↓
1. Checkout code
    ↓
2. Configure AWS credentials
    ↓
3. Login to ECR
    ↓
4. Build services with secrets:
    - Frontend: Built with REACT_APP_* variables baked in
    - Services: Regular Docker build
    ↓
5. Push images to ECR with tags (commit SHA + latest)
    ↓
6. SSH into EC2
    ↓
7. Create Docker network
    ↓
8. Deploy services in order with all environment variables:
    - Service E (base)
    - Service D → E
    - Service C → D
    - Service B → C
    - Service A → B
    - Frontend (with built-in REACT_APP vars)
    ↓
Containers Running with full configuration
```

---

## Quick Setup Checklist

- [ ] Create AWS IAM user with ECR permissions
- [ ] Generate AWS Access Key ID and Secret Access Key
- [ ] Create/Get EC2 instance with public IP
- [ ] Generate SSH key pair and download .pem file
- [ ] Set up PostgreSQL database (RDS or self-hosted)
- [ ] Add 26+ secrets to GitHub:
  - AWS (4): Account ID, Access Key, Secret Key, Region
  - EC2 (3): Host, User, SSH Key
  - Database (5): User, Host, Name, Password, Port
  - Config (2): NODE_ENV, DOCKER_NETWORK
  - Ports (5): Frontend, Service A-E
  - Containers (6): Frontend, Service A-E
  - Frontend URLs (11): Service URLs + Health URLs + timeout + debug
- [ ] Push code to `dev` branch (or adjust workflow trigger branch)
- [ ] Monitor GitHub Actions for deployment status

---

## Common Errors & Solutions

### "Missing required environment variables" in containers

**Problem**: Services crash on startup
**Solution**: Check that all DB_* secrets are set correctly:
```bash
sudo docker logs traffic-flow-service-a
```
Look for: `Missing required environment variables: DB_USER, DB_HOST, DB_NAME, DB_PASS, DB_PORT`

**Fix:**
1. Verify secrets in GitHub (Settings → Secrets)
2. Verify service URLs in docker run commands match container names
3. Check database is accessible from EC2

### Frontend shows "Cannot connect to Service A"

**Problem**: Frontend calls return 404 or connection refused
**Solution**: Frontend needs build-time environment variables

**Fix:**
1. Ensure all `REACT_APP_*` secrets are set in GitHub
2. These must match your EC2 IP and port numbers
3. Example: `REACT_APP_SERVICE_A_URL=http://54.123.45.67:3001/serviceA`
4. If changed, rebuild frontend (`docker build` will automatically use new values)

### "Cannot connect to database"

**Problem**: Services log `Error: connect ECONNREFUSED`
**Solution**: Database configuration issue

**Fix:**
1. Verify `DB_HOST` is correct (RDS endpoint or IP)
2. Check database is running and accepting connections
3. Verify security groups/firewall allows EC2 → Database traffic
4. Test locally: `psql -h DB_HOST -U DB_USER -d DB_NAME`

### "Failed to pull image from ECR"

**Problem**: Docker login fails or image not found
**Solution**: AWS credentials issue

**Fix:**
1. Verify `AWS_ACCOUNT_ID` is exact (12 digits)
2. Verify `AWS_REGION` is correct (must match ECR region)
3. Check AWS IAM permissions for the user
4. Check secrets haven't been accidentally modified

---

## Testing the Setup

### 1. Test GitHub Secrets
In GitHub Actions workflow, temporarily add this step:
```yaml
- name: Verify Secrets
  run: |
    echo "AWS Region: ${{ secrets.AWS_REGION }}"
    echo "DB Host: ${{ secrets.DB_HOST }}"
    echo "Frontend URL: ${{ secrets.REACT_APP_SERVICE_A_URL }}"
```

### 2. Test EC2 Connection
```bash
ssh -i your-key.pem ubuntu@${{ secrets.EC2_HOST }}
```

### 3. Test Database Connection
On EC2:
```bash
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT NOW();"
```

### 4. Monitor Deployment
```bash
ssh -i your-key.pem ubuntu@${{ secrets.EC2_HOST }}
sudo docker logs traffic-flow-service-a --follow
```

---

## Environment-Specific Configuration

### Development
```
NODE_ENV=development
REACT_APP_ENABLE_DEBUG=true
REACT_APP_REQUEST_TIMEOUT=30000
FRONTEND_PORT=8080
```

### Production
```
NODE_ENV=production
REACT_APP_ENABLE_DEBUG=false
REACT_APP_REQUEST_TIMEOUT=15000
FRONTEND_PORT=80
```

---

## Security Best Practices

✅ **DO:**
- Use AWS IAM user (not root credentials)
- Rotate database passwords regularly
- Use strong SSH key (4096-bit RSA)
- Store secrets in GitHub encrypted vault
- Restrict database to EC2 security group
- Use HTTPS for frontend in production

❌ **DON'T:**
- Commit `.pem` files to repository
- Use default database passwords
- Share AWS account credentials
- Use `.*_PASS` secrets in logs
- Set `REACT_APP_ENABLE_DEBUG=true` in production

For any issues, check:
- GitHub Actions workflow logs
- EC2 container logs: `sudo docker logs <container-name>`
- AWS CloudTrail for authentication errors
