#!/bin/bash

# SSL Certificate Setup Script for Vaultwarden
# This script obtains initial SSL certificates and starts the services

set -e

# Configuration
DOMAIN="vault.yourdomain.com"
EMAIL="your-email@yourdomain.com"
STAGING=0  # Set to 1 for testing with staging certificates

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔐 Vaultwarden SSL Certificate Setup${NC}"
echo "=================================="

# Check if domain is configured
if [ "$DOMAIN" = "vault.yourdomain.com" ]; then
    echo -e "${RED}❌ Error: Please update DOMAIN in this script${NC}"
    echo "Edit this script and set your actual domain name"
    exit 1
fi

# Check if email is configured
if [ "$EMAIL" = "your-email@yourdomain.com" ]; then
    echo -e "${RED}❌ Error: Please update EMAIL in this script${NC}"
    echo "Edit this script and set your actual email address"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Error: .env file not found${NC}"
    echo "Please create and configure your .env file first"
    exit 1
fi

# Check if docker-compose file exists
if [ ! -f "docker-compose.yml" ] && [ ! -f "ssl-setup.md" ]; then
    echo -e "${RED}❌ Error: docker-compose.yml not found${NC}"
    echo "Please ensure your docker-compose.yml file is in the current directory"
    exit 1
fi

echo -e "${YELLOW}📋 Configuration:${NC}"
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo "Staging: $([ $STAGING -eq 1 ] && echo 'Yes' || echo 'No')"
echo ""

# Confirm before proceeding
read -p "Continue with certificate setup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 1
fi

echo -e "${GREEN}🚀 Starting certificate setup...${NC}"

# Step 1: Create necessary directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p certbot/conf
mkdir -p certbot/www
mkdir -p nginx/conf

# Step 2: Generate dummy certificate for initial nginx start
echo -e "${YELLOW}🔑 Creating dummy certificate...${NC}"
mkdir -p "certbot/conf/live/$DOMAIN"

# Create dummy certificates
openssl req -x509 -nodes -newkey rsa:2048 -keyout "certbot/conf/live/$DOMAIN/privkey.pem" \
    -out "certbot/conf/live/$DOMAIN/fullchain.pem" -days 1 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN" 2>/dev/null

# Create chain file
cp "certbot/conf/live/$DOMAIN/fullchain.pem" "certbot/conf/live/$DOMAIN/chain.pem"

# Step 3: Start nginx with dummy certificate
echo -e "${YELLOW}🌐 Starting nginx with dummy certificate...${NC}"

# Update nginx configuration with correct domain
if [ -f "nginx-with-certbot.conf" ]; then
    sed "s/vault\.yourdomain\.com/$DOMAIN/g" nginx-with-certbot.conf > nginx.conf
else
    echo -e "${RED}❌ Error: nginx-with-certbot.conf not found${NC}"
    exit 1
fi

# Start only nginx and database first
docker-compose up -d db nginx

# Wait for nginx to start
echo -e "${YELLOW}⏳ Waiting for nginx to start...${NC}"
sleep 10

# Step 4: Delete dummy certificate and get real one
echo -e "${YELLOW}🔒 Obtaining real SSL certificate...${NC}"
rm -rf "certbot/conf/live/$DOMAIN"

# Determine certbot arguments
CERTBOT_ARGS="--webroot --webroot-path=/var/www/certbot --email $EMAIL --agree-tos --no-eff-email"

if [ $STAGING -eq 1 ]; then
    CERTBOT_ARGS="$CERTBOT_ARGS --staging"
fi

# Get certificate
docker-compose run --rm certbot certonly $CERTBOT_ARGS -d $DOMAIN

# Step 5: Reload nginx with real certificate
echo -e "${YELLOW}🔄 Reloading nginx with real certificate...${NC}"
docker-compose exec nginx nginx -s reload

# Step 6: Start all services
echo -e "${YELLOW}🚀 Starting all services...${NC}"
docker-compose up -d

# Step 7: Test certificate renewal
echo -e "${YELLOW}🔄 Testing certificate renewal...${NC}"
docker-compose run --rm certbot renew --dry-run

echo ""
echo -e "${GREEN}✅ SSL Certificate setup completed successfully!${NC}"
echo ""
echo -e "${GREEN}📝 Next steps:${NC}"
echo "1. Update your DNS to point $DOMAIN to this server"
echo "2. Configure your .env file with all required values"
echo "3. Set up Google OAuth credentials"
echo "4. Access your Vaultwarden instance at: https://$DOMAIN"
echo "5. Access admin panel at: https://$DOMAIN/admin"
echo ""
echo -e "${YELLOW}🔧 Useful commands:${NC}"
echo "View logs: docker-compose logs -f"
echo "Restart services: docker-compose restart"
echo "Stop services: docker-compose down"
echo "Renew certificates: docker-compose run --rm certbot renew"
echo ""
echo -e "${GREEN}🎉 Your Vaultwarden instance is ready!${NC}"