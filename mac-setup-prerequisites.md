# Mac Prerequisites for Vaultwarden Local Setup

## Required Software

### 1. Install Docker Desktop for Mac
```bash
# Option 1: Download from Docker website
# Go to: https://www.docker.com/products/docker-desktop/

# Option 2: Install via Homebrew
brew install --cask docker
```

### 2. Install Homebrew (if not already installed)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Install Additional Tools
```bash
# Install OpenSSL for generating tokens
brew install openssl

# Install mkcert for local SSL certificates
brew install mkcert

# Install nss (required for mkcert with Firefox)
brew install nss
```

## System Configuration

### 1. Docker Desktop Settings
After installing Docker Desktop:
1. Open Docker Desktop
2. Go to Settings → Resources → Advanced
3. Recommended settings for Vaultwarden:
   - **Memory**: 4GB minimum (8GB recommended)
   - **CPUs**: 2 minimum (4 recommended)
   - **Disk**: 20GB minimum

### 2. Enable Docker Compose V2
```bash
# Verify Docker Compose is available
docker compose version
```

## Network Configuration

### 1. Local Domain Setup
We'll use `vault.local` as our local domain:

```bash
# Add to /etc/hosts file
sudo nano /etc/hosts

# Add this line:
127.0.0.1    vault.local
```

### 2. Firewall Configuration (if needed)
```bash
# Check if firewall is enabled
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# If enabled, allow Docker
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/Docker.app/Contents/MacOS/Docker
```

## Verification

### Test Docker Installation
```bash
# Test Docker
docker run hello-world

# Test Docker Compose
docker compose version

# Check available resources
docker system info
```

### Test Network Configuration
```bash
# Test local domain resolution
ping vault.local
```

## Next Steps
Once prerequisites are installed:
1. ✅ Docker Desktop running
2. ✅ Local domain configured
3. ✅ Required tools installed
4. ✅ Network configuration complete

You're ready to proceed with the Vaultwarden setup!