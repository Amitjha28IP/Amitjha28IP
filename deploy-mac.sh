#!/bin/bash

# Vaultwarden Mac/Linux Deployment Script
# This script sets up and deploys Vaultwarden locally on Mac/Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="vault.local"
COMPOSE_FILE="docker-compose.local.yml"

show_help() {
    echo -e "${GREEN}Vaultwarden Mac/Linux Deployment Script${NC}"
    echo -e "${GREEN}=======================================${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./deploy-mac.sh setup     # Initial setup (SSL, hosts, environment)"
    echo "  ./deploy-mac.sh start     # Start Vaultwarden services"
    echo "  ./deploy-mac.sh stop      # Stop Vaultwarden services"
    echo "  ./deploy-mac.sh restart   # Restart Vaultwarden services"
    echo "  ./deploy-mac.sh logs      # Show service logs"
    echo "  ./deploy-mac.sh clean     # Clean up containers and volumes"
    echo "  ./deploy-mac.sh help      # Show this help"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  # First time setup"
    echo "  ./deploy-mac.sh setup"
    echo ""
    echo "  # Start services"
    echo "  ./deploy-mac.sh start"
    echo ""
    echo "  # View logs"
    echo "  ./deploy-mac.sh logs"
}

check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check Docker
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✅ Docker is available${NC}"
    else
        echo -e "${RED}❌ Docker is not available${NC}"
        echo -e "${YELLOW}   Please install Docker Desktop for Mac${NC}"
        return 1
    fi
    
    # Check Docker Compose
    if docker compose version &> /dev/null; then
        echo -e "${GREEN}✅ Docker Compose is available${NC}"
    else
        echo -e "${RED}❌ Docker Compose is not available${NC}"
        return 1
    fi
    
    # Check if Docker is running
    if docker ps &> /dev/null; then
        echo -e "${GREEN}✅ Docker daemon is running${NC}"
    else
        echo -e "${RED}❌ Docker daemon is not running${NC}"
        echo -e "${YELLOW}   Please start Docker Desktop${NC}"
        return 1
    fi
    
    # Check for mkcert on Mac
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v mkcert &> /dev/null; then
            echo -e "${GREEN}✅ mkcert is available${NC}"
        else
            echo -e "${YELLOW}⚠️  mkcert not found, will attempt to install${NC}"
        fi
    fi
    
    return 0
}

setup_environment() {
    echo -e "${GREEN}🚀 Setting up Vaultwarden environment...${NC}"
    
    # Check prerequisites
    if ! check_prerequisites; then
        echo -e "${RED}❌ Prerequisites not met. Please install required software.${NC}"
        return 1
    fi
    
    # Setup hosts file
    echo -e "${BLUE}📝 Configuring hosts file...${NC}"
    if ! grep -q "vault.local" /etc/hosts; then
        echo "127.0.0.1    vault.local" | sudo tee -a /etc/hosts > /dev/null
        echo -e "${GREEN}✅ Added vault.local to hosts file${NC}"
    else
        echo -e "${GREEN}✅ vault.local already exists in hosts file${NC}"
    fi
    
    # Flush DNS cache (Mac specific)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
        echo -e "${GREEN}✅ DNS cache flushed${NC}"
    fi
    
    # Setup SSL certificates
    echo -e "${BLUE}🔐 Setting up SSL certificates...${NC}"
    if [[ -f "./local-ssl-setup.sh" ]]; then
        chmod +x ./local-ssl-setup.sh
        ./local-ssl-setup.sh
    else
        echo -e "${YELLOW}⚠️  SSL setup script not found${NC}"
        echo -e "${YELLOW}   Please run local-ssl-setup.sh manually${NC}"
    fi
    
    # Setup environment file
    echo -e "${BLUE}⚙️  Setting up environment file...${NC}"
    if [[ ! -f ".env" ]]; then
        if [[ -f ".env.local" ]]; then
            cp ".env.local" ".env"
            echo -e "${GREEN}✅ Created .env from template${NC}"
            echo -e "${YELLOW}⚠️  Please edit .env file with your actual values:${NC}"
            echo -e "${YELLOW}   - ADMIN_TOKEN (generate with: openssl rand -base64 48)${NC}"
            echo -e "${YELLOW}   - GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET${NC}"
        else
            echo -e "${RED}❌ .env.local template not found${NC}"
        fi
    else
        echo -e "${GREEN}✅ .env file already exists${NC}"
    fi
    
    # Make scripts executable
    chmod +x deploy-mac.sh 2>/dev/null || true
    chmod +x local-ssl-setup.sh 2>/dev/null || true
    
    echo ""
    echo -e "${GREEN}✅ Setup completed!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Edit .env file with your configuration"
    echo "  2. Set up Google OAuth (see google-oauth-local-setup.md)"
    echo "  3. Run: ./deploy-mac.sh start"
}

start_services() {
    echo -e "${GREEN}🚀 Starting Vaultwarden services...${NC}"
    
    if ! check_prerequisites; then
        return 1
    fi
    
    if [[ ! -f ".env" ]]; then
        echo -e "${RED}❌ .env file not found${NC}"
        echo -e "${YELLOW}   Run: ./deploy-mac.sh setup${NC}"
        return 1
    fi
    
    if [[ ! -f "ssl/cert.pem" ]]; then
        echo -e "${RED}❌ SSL certificates not found${NC}"
        echo -e "${YELLOW}   Run: ./deploy-mac.sh setup${NC}"
        return 1
    fi
    
    docker compose -f $COMPOSE_FILE up -d
    
    echo -e "${GREEN}✅ Services started successfully!${NC}"
    echo ""
    echo -e "${GREEN}🌐 Access Vaultwarden at: https://vault.local${NC}"
    echo -e "${GREEN}🔧 Admin panel at: https://vault.local/admin${NC}"
    echo ""
    echo -e "${YELLOW}📋 Service status:${NC}"
    docker compose -f $COMPOSE_FILE ps
}

stop_services() {
    echo -e "${YELLOW}⏹️  Stopping Vaultwarden services...${NC}"
    docker compose -f $COMPOSE_FILE down
    echo -e "${GREEN}✅ Services stopped successfully!${NC}"
}

restart_services() {
    echo -e "${BLUE}🔄 Restarting Vaultwarden services...${NC}"
    stop_services
    sleep 2
    start_services
}

show_logs() {
    echo -e "${BLUE}📋 Showing Vaultwarden logs...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to exit logs${NC}"
    echo ""
    docker compose -f $COMPOSE_FILE logs -f
}

clean_environment() {
    echo -e "${YELLOW}🧹 Cleaning up Vaultwarden environment...${NC}"
    
    read -p "This will remove all containers, volumes, and data. Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose -f $COMPOSE_FILE down -v --remove-orphans
        docker system prune -f
        echo -e "${GREEN}✅ Environment cleaned successfully!${NC}"
    else
        echo -e "${YELLOW}❌ Cleanup cancelled${NC}"
    fi
}

generate_admin_token() {
    echo -e "${BLUE}🔑 Generating admin token...${NC}"
    if command -v openssl &> /dev/null; then
        TOKEN=$(openssl rand -base64 48)
        echo -e "${GREEN}Generated admin token:${NC}"
        echo "$TOKEN"
        echo ""
        echo -e "${YELLOW}Add this to your .env file:${NC}"
        echo "ADMIN_TOKEN=$TOKEN"
    else
        echo -e "${RED}❌ OpenSSL not available${NC}"
        echo -e "${YELLOW}Please install OpenSSL or generate token manually${NC}"
    fi
}

# Main script logic
case "${1:-}" in
    setup)
        setup_environment
        ;;
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_environment
        ;;
    token)
        generate_admin_token
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ No action specified${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac