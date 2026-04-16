#!/bin/bash

# Local Development Startup Script
# This script helps start all services individually for local development
#
# IMPORTANT: Before running this script:
# 1. Copy .env.example to .env in each service directory
# 2. Update the values in .env files for your local environment
# 3. Make sure PostgreSQL is running (the script will start it if needed)

set -e

echo "🚀 Starting TRAFFIC_FLOW Microservices (Local Development)"
echo "========================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

print_status "Docker is running"

# Create network if it doesn't exist
if ! docker network ls | grep -q appnet; then
    docker network create appnet
    print_status "Created Docker network 'appnet'"
else
    print_status "Docker network 'appnet' already exists"
fi

# Start PostgreSQL if not running
if ! docker ps | grep -q postgres; then
    docker run -d --name postgres -p 5432:5432 \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=postgres \
        -e POSTGRES_DB=microservices \
        postgres:15
    print_status "Started PostgreSQL database"
    sleep 5
else
    print_status "PostgreSQL is already running"
fi

# Connect postgres to network if not connected
if ! docker network inspect appnet | grep -q postgres; then
    docker network connect appnet postgres
    print_status "Connected PostgreSQL to appnet"
fi

# Function to start a service
start_service() {
    local service_name=$1
    local port=$2
    local folder=$3

    if docker ps | grep -q $service_name; then
        print_warning "$service_name is already running"
        return
    fi

    echo "Building and starting $service_name..."

    # Build the image
    docker build -t $service_name ./$folder

    # Run the container
    case $service_name in
        servicea)
            docker run -d --name $service_name --network appnet -p $port:$port \
                -e DB_HOST=postgres -e DB_PORT=5432 -e DB_USER=postgres -e DB_PASS=postgres -e DB_NAME=microservices \
                -e SERVICE_B_URL=http://serviceb:3002/serviceB \
                -e PORT=$port \
                $service_name
            ;;
        serviceb)
            docker run -d --name $service_name --network appnet -p $port:$port \
                -e DB_HOST=postgres -e DB_PORT=5432 -e DB_USER=postgres -e DB_PASS=postgres -e DB_NAME=microservices \
                -e SERVICE_C_URL=http://servicec:3003/serviceC \
                -e PORT=$port \
                $service_name
            ;;
        servicec)
            docker run -d --name $service_name --network appnet -p $port:$port \
                -e DB_HOST=postgres -e DB_PORT=5432 -e DB_USER=postgres -e DB_PASS=postgres -e DB_NAME=microservices \
                -e SERVICE_D_URL=http://serviced:3004/serviceD \
                -e PORT=$port \
                $service_name
            ;;
        serviced)
            docker run -d --name $service_name --network appnet -p $port:$port \
                -e DB_HOST=postgres -e DB_PORT=5432 -e DB_USER=postgres -e DB_PASS=postgres -e DB_NAME=microservices \
                -e SERVICE_E_URL=http://servicee:3005/serviceE \
                -e PORT=$port \
                $service_name
            ;;
        servicee)
            docker run -d --name $service_name --network appnet -p $port:$port \
                -e DB_HOST=postgres -e DB_PORT=5432 -e DB_USER=postgres -e DB_PASS=postgres -e DB_NAME=microservices \
                -e PORT=$port \
                $service_name
            ;;
        frontend)
            docker run -d --name $service_name --network appnet -p 3000:80 \
                -e REACT_APP_SERVICE_A_URL=/api/serviceA/ \
                -e REACT_APP_SERVICE_A_HEALTH=/api/serviceA/health \
                -e REACT_APP_SERVICE_B_HEALTH=/api/serviceB/health \
                -e REACT_APP_SERVICE_C_HEALTH=/api/serviceC/health \
                -e REACT_APP_SERVICE_D_HEALTH=/api/serviceD/health \
                -e REACT_APP_SERVICE_E_HEALTH=/api/serviceE/health \
                -e REACT_APP_REQUEST_TIMEOUT=15000 \
                -e REACT_APP_ENABLE_DEBUG=true \
                $service_name
            ;;
    esac

    print_status "Started $service_name on port $port"
}

# Start services in order
start_service "servicea" "3001" "serviceA"
start_service "serviceb" "3002" "serviceB"
start_service "servicec" "3003" "serviceC"
start_service "serviced" "3004" "serviceD"
start_service "servicee" "3005" "serviceE"
start_service "frontend" "80" "frontend"

echo ""
echo -e "${GREEN}🎉 All services started successfully!${NC}"
echo ""
echo "📋 Service URLs:"
echo "   Frontend:    http://localhost:3000"
echo "   Service A:   http://localhost:3001"
echo "   Service B:   http://localhost:3002"
echo "   Service C:   http://localhost:3003"
echo "   Service D:   http://localhost:3004"
echo "   Service E:   http://localhost:3005"
echo "   Database:    localhost:5432"
echo ""
echo "🔍 Health checks:"
echo "   Overall:     curl http://localhost/health"
echo "   Services:    curl http://localhost:3001/health"
echo ""
echo "🛑 To stop all services: docker rm -f frontend servicea serviceb servicec serviced servicee postgres"
echo "🧹 To clean up: docker system prune -a"