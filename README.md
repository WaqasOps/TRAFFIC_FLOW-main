<div align="center">

![ECS/EKS Microservices Banner](./.readme_assets/Banner.png)

# 🚀 ECS/EKS Microservices Project

### _Cloud-Native Microservices Architecture with Docker & AWS_

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Express](https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com/)

[Features](#-features) • [Architecture](#-architecture) • [Quick Start](#-quick-start) • [Deployment](#-deployment) • [Documentation](#-documentation)

</div>

---

## 📋 Overview

This project is a **production-ready microservices-based application** built with modern cloud-native technologies. It demonstrates a **sophisticated service-to-service call chain** with comprehensive health monitoring, database integration, and centralized logging.

### 🎯 Key Highlights

- **Frontend:** React SPA with Nginx (S3 + CloudFront ready)
- **Backend Services:** Service A → Service B → Service C → Service D → Service E
- **Database:** PostgreSQL with connection pooling
- **Containerization:** Multi-stage Docker builds for optimal image size
- **Orchestration:** Docker Compose (local) | AWS ECS/EKS (production)
- **Observability:** Winston logging, health checks, and monitoring endpoints

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🔐 **Production-Ready**
- Health check endpoints for all services
- Graceful shutdown handling
- Error boundary implementation
- Environment-based configuration

</td>
<td width="50%">

### 📊 **Observability**
- Centralized logging with Winston
- Request/response tracking
- Real-time status monitoring
- Service health dashboards

</td>
</tr>
<tr>
<td width="50%">

### 🐳 **Container Native**
- Optimized Docker images
- Multi-stage builds
- Docker Compose orchestration
- ECS/EKS deployment ready

</td>
<td width="50%">

### ☁️ **AWS Integration**
- ECR image repository
- ECS task definitions
- S3 + CloudFront hosting
- RDS PostgreSQL support

</td>
</tr>
</table>

---

## 🏗️ Architecture

<div align="center">

![Architecture Diagram](./.readme_assets/Architecture.png)

</div>

### Service Flow

```mermaid
graph LR
    A[🌐 Frontend<br/>React + Nginx] --> B[🔷 Service A<br/>Port 3001]
    B --> C[🔷 Service B<br/>Port 3002]
    C --> D[🔷 Service C<br/>Port 3003]
    D --> E[🔷 Service D<br/>Port 3004]
    E --> F[🔷 Service E<br/>Port 3005]
    F --> G[(🗄️ PostgreSQL<br/>Database)]
    
    style A fill:#61dafb,stroke:#20232a,stroke-width:2px
    style B fill:#68a063,stroke:#333,stroke-width:2px
    style C fill:#68a063,stroke:#333,stroke-width:2px
    style D fill:#68a063,stroke:#333,stroke-width:2px
    style E fill:#68a063,stroke:#333,stroke-width:2px
    style F fill:#68a063,stroke:#333,stroke-width:2px
    style G fill:#336791,stroke:#fff,stroke-width:2px
```

### 📁 Project Structure

```
TRAFFIC_FLOW-main/
├── 🔧 start-local.sh           # Automated local startup script
├── 🔧 setup-local.sh           # Environment setup script
├── � nginx-proxy.conf         # Nginx proxy configuration for EC2
├── 🎨 frontend/                # React SPA frontend
│   ├── src/                    # React source code
│   ├── public/                 # Static assets
│   ├── dockerfile              # Multi-stage build
│   ├── nginx.conf              # Container nginx config
│   └── .env.example            # Environment variables template
├── 🔷 serviceA/                # Entry point service
│   ├── app.js                  # Express application
│   ├── dockerfile              # Service container
│   ├── package.json            # Dependencies
│   └── .env.example            # Environment variables template
├── 🔷 serviceB/                # Processing service
├── 🔷 serviceC/                # Business logic service
├── 🔷 serviceD/                # Integration service
└── 🔷 serviceE/                # Data persistence service
```

### 🔄 Service Communication

| Service | Port | Endpoint | Health Check | Database |
|---------|------|----------|--------------|----------|
| **Frontend** | 3000 | `/` | N/A | ❌ |
| **Service A** | 3001 | `/serviceA` | `/health` | ✅ |
| **Service B** | 3002 | `/serviceB` | `/health` | ✅ |
| **Service C** | 3003 | `/serviceC` | `/health` | ✅ |
| **Service D** | 3004 | `/serviceD` | `/health` | ✅ |
| **Service E** | 3005 | `/serviceE` | `/health` | ✅ |

---

## 🚀 Quick Start

### Prerequisites

Ensure you have the following installed:

```bash
✓ Docker (v20.10+)
✓ Node.js (v18+)
✓ AWS CLI (v2.0+)
✓ Git
```

### 🎬 Local Development

1️⃣ **Clone the repository**

```bash
git clone <repo-url>
cd TRAFFIC_FLOW-main
```

2️⃣ **Setup environment files**

```bash
# Run the setup script to create .env files from examples
./setup-local.sh

# Edit the .env files with your local configuration
# Each service has its own .env file
```

3️⃣ **Start all services**

```bash
# Option 1: Use the automated script
./start-local.sh

# Option 2: Manual startup (see script for details)
```

3️⃣ **Access the application**

- **Frontend:** http://localhost
- **Service A:** http://localhost:3001
- **Service B:** http://localhost:3002
- **Service C:** http://localhost:3003
- **Service D:** http://localhost:3004
- **Service E:** http://localhost:3005
- **Database:** localhost:5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=microservices
NEXT_SERVICE_URL=http://service-b:3002
```

**Frontend (.env)**
```env
REACT_APP_SERVICE_A_URL=http://localhost:3001
REACT_APP_SERVICE_B_URL=http://localhost:3002
REACT_APP_SERVICE_C_URL=http://localhost:3003
REACT_APP_SERVICE_D_URL=http://localhost:3004
REACT_APP_SERVICE_E_URL=http://localhost:3005
```

3️⃣ **Start all services**

```bash
docker-compose up --build
```

4️⃣ **Verify deployment**

```bash
# Check all containers are running
docker-compose ps

# Test health endpoints
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3003/health
curl http://localhost:3004/health
curl http://localhost:3005/health
```

5️⃣ **Access the application**

| Service | URL | Description |
|---------|-----|-------------|
| 🌐 **Frontend** | http://localhost:3000 | React dashboard |
| 🔷 **Service A** | http://localhost:3001/serviceA | API endpoint |
| 🔷 **Service B** | http://localhost:3002/serviceB | API endpoint |
| 🔷 **Service C** | http://localhost:3003/serviceC | API endpoint |
| 🔷 **Service D** | http://localhost:3004/serviceD | API endpoint |
| 🔷 **Service E** | http://localhost:3005/serviceE | API endpoint |

---

## ☁️ Deployment

### � Automated CI/CD Pipeline

The GitHub Actions pipeline automatically:
1. Builds Docker images for all services
2. Pushes images to Amazon ECR with proper tagging
3. Deploys containers to EC2 with internal networking
4. Runs health checks post-deployment

**Note:** Nginx proxy configuration must be set up manually on EC2 (see EC2 Setup section).

### 🔧 Manual Deployment

For manual deployment to EC2:

```bash
# 1. SSH into your EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# 2. Set up nginx proxy manually (see EC2 Setup section)
sudo cp nginx-proxy.conf /etc/nginx/sites-available/traffic-flow
sudo ln -sf /etc/nginx/sites-available/traffic-flow /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx

# 3. Pull and run containers
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin YOUR_ECR_REGISTRY

# Create network
docker network create appnet
docker network connect appnet postgres

# Run services (see pipeline for exact environment variables)
docker run -d --name servicea --network appnet -p 3001:3001 \
  -e DB_HOST=postgres -e DB_USER=your_user -e DB_PASS=your_pass -e DB_NAME=your_db \
  -e SERVICE_B_URL=http://serviceb:3002/serviceB \
  your-registry/servicea:latest

# Repeat for other services...

# Run frontend (exposed on port 80)
docker run -d --name frontend --network appnet -p 80:80 \
  -e REACT_APP_SERVICE_A_URL=/api/serviceA/ \
  your-registry/frontend:latest
```
# Create cluster
aws ecs create-cluster --cluster-name microservices-cluster

# Verify cluster
aws ecs describe-clusters --clusters microservices-cluster
```

#### Step 4: Deploy Services

**Using AWS Console:**
1. Navigate to ECS → Task Definitions
2. Create task definition for each service
3. Configure container settings (image, port, environment)
4. Create ECS services with load balancing

**Using ECS CLI:**
```bash
ecs-cli compose --file docker-compose.yaml \
  --project-name microservices \
  service up \
  --cluster microservices-cluster \
  --launch-type FARGATE
```

---

### 🖥️ EC2 Setup

#### Prerequisites

- Ubuntu 20.04+ EC2 instance
- Nginx installed (`sudo apt install nginx`)
- Docker and Docker Compose installed
- PostgreSQL running (either in container or RDS)

#### Nginx Proxy Configuration

1. **Copy the nginx configuration:**

```bash
sudo cp nginx-proxy.conf /etc/nginx/sites-available/traffic-flow
sudo ln -sf /etc/nginx/sites-available/traffic-flow /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
```

2. **Test and reload nginx:**

```bash
sudo nginx -t
sudo systemctl reload nginx
```

3. **Verify nginx is running:**

```bash
sudo systemctl status nginx
curl http://localhost  # Should show frontend
```

#### Database Setup

**Option 1: PostgreSQL in Docker**

```bash
docker run -d --name postgres \
  -e POSTGRES_USER=your_user \
  -e POSTGRES_PASSWORD=your_pass \
  -e POSTGRES_DB=your_db \
  -p 5432:5432 \
  postgres:13-alpine
```

**Option 2: AWS RDS PostgreSQL**

Use the RDS endpoint as `DB_HOST` in your environment variables.

---

### 🌐 Frontend Hosting (S3 + CloudFront)

#### Step 1: Build Production React App

```bash
cd frontend
npm install
npm run build
```

#### Step 2: Upload to S3

```bash
# Create S3 bucket
aws s3 mb s3://microservices-frontend

# Enable static website hosting
aws s3 website s3://microservices-frontend \
  --index-document index.html \
  --error-document index.html

# Upload build files
aws s3 sync build/ s3://microservices-frontend --delete

# Make public
aws s3 cp s3://microservices-frontend s3://microservices-frontend \
  --recursive --acl public-read
```

#### Step 3: Configure CloudFront

```bash
# Create CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name microservices-frontend.s3.amazonaws.com \
  --default-root-object index.html
```

---

## 📊 Observability & Monitoring

### 📝 Logging

All backend services use **Winston** for structured logging:

```javascript
// Log format
{
  "timestamp": "2026-02-08T00:00:00.000Z",
  "level": "info",
  "message": "Request received",
  "service": "serviceA",
  "method": "GET",
  "path": "/serviceA",
  "correlationId": "uuid-v4"
}
```

### 🏥 Health Checks

Each service exposes a `/health` endpoint:

```bash
# Health check response
{
  "status": "healthy",
  "service": "serviceA",
  "timestamp": "2026-02-08T00:00:00.000Z",
  "uptime": 3600,
  "database": "connected"
}
```

### 📈 Monitoring Stack

- **CloudWatch**: Centralized logging and metrics
- **X-Ray**: Distributed tracing
- **ECS Service Metrics**: CPU, memory, network
- **Custom Metrics**: Request latency, error rates

---

## 🔧 Troubleshooting

### Common Issues

<details>
<summary><b>🔴 Connection Refused / ERR_CONNECTION_RESET</b></summary>

**Symptoms:**
- `ECONNREFUSED` errors
- `net::ERR_CONNECTION_RESET`

**Solutions:**
```bash
# Check if services are running
docker-compose ps

# Check logs
docker-compose logs serviceA

# Verify port mappings
docker port <container-name>

# Restart services
docker-compose restart
```
</details>

<details>
<summary><b>🔴 Database Connection Issues</b></summary>

**Symptoms:**
- "Cannot connect to PostgreSQL"
- Service health check fails

**Solutions:**
```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Verify environment variables
docker-compose exec serviceA env | grep DB_

# Test database connection
docker-compose exec postgres psql -U postgres -d microservices
```
</details>

<details>
<summary><b>🔴 Frontend Cannot Reach Backend</b></summary>

**Symptoms:**
- API calls fail from browser
- CORS errors

**Solutions:**
```bash
# Check environment variables
cat frontend/.env

# Verify REACT_APP_ prefix
grep REACT_APP_ frontend/.env

# Rebuild frontend
docker-compose up --build frontend
```
</details>

---

## 📚 Documentation

### API Endpoints

#### Service A

```http
GET /serviceA
```

**Response:**
```json
{
  "message": "Response from Service A",
  "timestamp": "2026-02-08T00:00:00.000Z",
  "downstream": {
    "serviceB": "Response from Service B",
    "serviceC": "Response from Service C"
  }
}
```

#### Health Check

```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "service": "serviceA",
  "timestamp": "2026-02-08T00:00:00.000Z",
  "uptime": 3600,
  "database": "connected"
}
```

---

## 🛠️ Technology Stack

<div align="center">

| Category | Technologies |
|----------|-------------|
| **Frontend** | React, Nginx, HTML5, CSS3 |
| **Backend** | Node.js, Express.js, Winston |
| **Database** | PostgreSQL, pg (node-postgres) |
| **Containerization** | Docker, Shell Scripts |
| **Cloud Infrastructure** | AWS EC2, ECR |
| **Storage** | Amazon S3, CloudFront |
| **Monitoring** | CloudWatch, X-Ray |
| **CI/CD** | GitHub Actions (optional) |

</div>

---

## 🔧 Configuration

### Environment Variables Setup

**All configuration is done via environment variables passed to containers. No .env files are used in production.**

#### For Local Development
1. Copy `.env.example` to `.env` in each service directory
2. Update values for your local setup
3. Use the `start-local.sh` script to run all services

#### For Production (GitHub Actions)
All values are stored as GitHub Secrets and passed to containers during deployment.

### Required GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key ID | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret access key | `secret...` |
| `ECR_REGISTRY` | Your ECR repository URI | `123456789.dkr.ecr.ap-south-1.amazonaws.com` |
| `EC2_HOST` | EC2 instance public IP or DNS | `13.201.9.34` |
| `EC2_USERNAME` | SSH username for EC2 | `ubuntu` |
| `EC2_SSH_KEY` | Private SSH key (base64 encoded) | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `EC2_PUBLIC_IP` | Public IP for frontend URLs | `13.201.9.34` |
| `DB_USER` | PostgreSQL username | `postgres` |
| `DB_PASS` | PostgreSQL password | `your_secure_password` |
| `DB_NAME` | PostgreSQL database name | `microservices` |

### EC2 Instance Setup

1. **Launch EC2 instance** with Ubuntu 22.04 LTS
2. **Install Docker**:
   ```bash
   sudo apt update
   sudo apt install docker.io
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -aG docker ubuntu
   ```

3. **Install Nginx**:
   ```bash
   sudo apt install nginx
   sudo systemctl enable nginx
   ```

4. **Start PostgreSQL container** (run once):
   ```bash
   sudo docker run -d --name postgres -p 5432:5432 \
     -e POSTGRES_USER=your_db_user \
     -e POSTGRES_PASSWORD=your_db_password \
     -e POSTGRES_DB=your_db_name \
     postgres:15
   ```

5. **Configure Security Groups**:
   - Allow SSH (port 22) from your IP
   - Allow HTTP (port 80) from anywhere
   - Allow ports 3001-3005 from EC2 security group (internal only)
   - Allow PostgreSQL (port 5432) from EC2 security group (internal only)

6. **Generate SSH Key Pair**:
   ```bash
   # On your local machine
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   ssh-copy-id ubuntu@your-ec2-ip
   
   # Get private key for GitHub secret (base64 encoded)
   cat ~/.ssh/id_rsa | base64 -w 0
   ```

### Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐
│   Nginx Proxy   │    │   Containers    │
│   (Port 80)     │    │   (Internal)    │
│                 │    │                 │
│ / → frontend    │────▶│ Frontend:80    │
│ /api/* → APIs   │    │ ServiceA:3001  │
└─────────────────┘    │ ServiceB:3002  │
                       │ ServiceC:3003  │
                       │ ServiceD:3004  │
                       │ ServiceE:3005  │
                       │ Postgres:5432  │
                       └─────────────────┘
```

- **Nginx Proxy**: Runs on EC2 host, routes requests to containers
- **Container Communication**: All containers communicate via `localhost`
- **Frontend**: Runs on port 80 internally, served via nginx on port 80
- **Services**: Run on ports 3001-3005, accessible via nginx proxy

---

## 🎓 Best Practices

- ✅ **Environment Variables**: All configuration through container environment variables
- ✅ **Health Checks**: Every service has `/health` endpoint
- ✅ **Graceful Shutdown**: Proper SIGTERM handling
- ✅ **Logging**: Structured logging with correlation IDs
- ✅ **Error Handling**: Comprehensive error boundaries
- ✅ **Security**: No secrets in code, IAM roles for AWS
- ✅ **Docker**: Multi-stage builds, minimal base images
- ✅ **Database**: Connection pooling, prepared statements

---

## 📝 Notes

> ⚠️ **Important Configuration Rules:**
> - All React environment variables **must** start with `REACT_APP_`
> - Backend services require `DB_*` and `NEXT_SERVICE_URL` variables
> - For local development, copy `.env.example` to `.env` in each service
> - For production, all configuration is done via GitHub Secrets
> - Never commit `.env` files to version control

> 💡 **Performance Tips:**
> - Use connection pooling for database connections
> - Implement caching where appropriate
> - Enable gzip compression in Nginx
> - Use CloudFront for global content delivery

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- AWS ECS/EKS documentation
- Docker and Node.js communities
- React and Express.js teams
- PostgreSQL contributors

---

<div align="center">

### 🌟 If you find this project useful, please consider giving it a star! 🌟

![Visitors](https://visitor-badge.laobi.icu/badge?page_id=aliakbarkhan-DevOps.TRAFFIC_FLOW)
[![GitHub stars](https://img.shields.io/github/stars/aliakbarkhan-DevOps/TRAFFIC_FLOW?style=social)](https://github.com/aliakbarkhan-DevOps/TRAFFIC_FLOW)
[![GitHub forks](https://img.shields.io/github/forks/aliakbarkhan-DevOps/TRAFFIC_FLOW?style=social)](https://github.com/aliakbarkhan-DevOps/TRAFFIC_FLOW)
![AWS](https://img.shields.io/badge/AWS-ECS%20%7C%20EKS-orange?logo=amazon-aws)
![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)

---

**[⬆ Back to Top](#-eceks-microservices-project)**

</div>