#!/bin/bash

# Local SSL Certificate Setup for Mac
# This script creates trusted local SSL certificates for Vaultwarden

set -e

# Configuration
DOMAIN="vault.local"
CERT_DIR="./ssl"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔐 Setting up Local SSL Certificates for Mac${NC}"
echo "=============================================="

# Check if mkcert is installed
if ! command -v mkcert &> /dev/null; then
    echo -e "${RED}❌ mkcert is not installed${NC}"
    echo -e "${YELLOW}Installing mkcert via Homebrew...${NC}"
    brew install mkcert
    brew install nss  # For Firefox support
fi

# Create certificate directory
echo -e "${BLUE}📁 Creating certificate directory...${NC}"
mkdir -p $CERT_DIR

# Install local CA
echo -e "${BLUE}🏛️  Installing local Certificate Authority...${NC}"
mkcert -install

# Generate certificate for local domain
echo -e "${BLUE}📜 Generating SSL certificate for $DOMAIN...${NC}"
mkcert -cert-file $CERT_DIR/cert.pem -key-file $CERT_DIR/key.pem $DOMAIN localhost 127.0.0.1 ::1

# Set proper permissions
chmod 644 $CERT_DIR/cert.pem
chmod 600 $CERT_DIR/key.pem

# Verify certificates
echo -e "${BLUE}🔍 Verifying certificate...${NC}"
openssl x509 -in $CERT_DIR/cert.pem -text -noout | grep -A 1 "Subject:"

echo -e "${GREEN}✅ SSL certificates created successfully!${NC}"
echo ""
echo -e "${YELLOW}Certificate files created:${NC}"
echo "  - Certificate: $CERT_DIR/cert.pem"
echo "  - Private Key: $CERT_DIR/key.pem"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. The certificates are now trusted by your Mac"
echo "  2. Firefox users: Restart Firefox for certificate trust"
echo "  3. Chrome/Safari: Should work immediately"
echo ""
echo -e "${GREEN}🚀 Ready to start Vaultwarden with HTTPS!${NC}"