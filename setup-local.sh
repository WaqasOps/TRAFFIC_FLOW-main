#!/bin/bash

# Setup script for local development
# This script helps set up environment files for local development

set -e

echo "🚀 Setting up TRAFFIC_FLOW for Local Development"
echo "================================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Check if .env files already exist
services=("serviceA" "serviceB" "serviceC" "serviceD" "serviceE" "frontend")

echo "Checking for existing .env files..."
for service in "${services[@]}"; do
    if [ -f "$service/.env" ]; then
        print_warning "$service/.env already exists - skipping"
    else
        if [ -f "$service/.env.example" ]; then
            cp "$service/.env.example" "$service/.env"
            print_status "Created $service/.env from .env.example"
        else
            print_error "$service/.env.example not found!"
        fi
    fi
done

echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo "📝 Next steps:"
echo "   1. Edit the .env files in each service directory with your local configuration"
echo "   2. Run ./start-local.sh to start all services"
echo "   3. (Optional) Install nginx locally and use nginx-proxy.conf for full proxy experience:"
echo "      sudo cp nginx-proxy.conf /etc/nginx/sites-available/traffic-flow"
echo "      sudo ln -sf /etc/nginx/sites-available/traffic-flow /etc/nginx/sites-enabled/"
echo "      sudo nginx -t && sudo systemctl reload nginx"
echo ""
echo "📋 Service URLs after startup:"
echo "   Frontend:    http://localhost:3000 (with nginx on port 80 internally)"
echo "   Service A:   http://localhost:3001"
echo "   Service B:   http://localhost:3002"
echo "   Service C:   http://localhost:3003"
echo "   Service D:   http://localhost:3004"
echo "   Service E:   http://localhost:3005"
echo "   Database:    localhost:5432"