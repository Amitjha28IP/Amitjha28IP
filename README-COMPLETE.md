# Vaultwarden Complete Setup - Mac & Windows

A complete Vaultwarden deployment with **all your requirements**:

✅ **Google Login Support** - OAuth2/OIDC integration  
✅ **Username/Password** - Standard password management  
✅ **TOTP Add-on** - Built-in TOTP/MFA support  
✅ **Secure File Sharing** - Bitwarden Send for encrypted file sharing  

## 🚀 Quick Start

### 🍎 For Mac Users

1. **Prerequisites & Setup**
   ```bash
   # Install prerequisites
   brew install docker mkcert openssl
   
   # Clone and setup
   git clone <your-repo> vaultwarden-setup
   cd vaultwarden-setup
   
   # Run automated setup
   ./deploy-mac.sh setup
   ```

2. **Configure Environment**
   ```bash
   # Edit environment file
   nano .env
   
   # Generate admin token
   ./deploy-mac.sh token
   
   # Set up Google OAuth (see google-oauth-local-setup.md)
   ```

3. **Start Services**
   ```bash
   ./deploy-mac.sh start
   
   # Access at: https://vault.local
   # Admin panel: https://vault.local/admin
   ```

### 🪟 For Windows Users

1. **Prerequisites & Setup**
   ```powershell
   # Install Docker Desktop, mkcert, OpenSSL (see windows-setup-prerequisites.md)
   
   # Clone and setup
   git clone <your-repo> vaultwarden-setup
   cd vaultwarden-setup
   
   # Run automated setup (as Administrator)
   .\deploy-windows.ps1 -Setup
   ```

2. **Configure Environment**
   ```powershell
   # Edit environment file
   notepad .env
   
   # Generate admin token
   [System.Convert]::ToBase64String((1..48 | ForEach {Get-Random -Maximum 256}))
   
   # Set up Google OAuth (see google-oauth-local-setup.md)
   ```

3. **Start Services**
   ```powershell
   .\deploy-windows.ps1 -Start
   
   # Access at: https://vault.local
   # Admin panel: https://vault.local/admin
   ```

## 📋 Requirements Met

### 1. ✅ Google Login Support
- **OAuth2/OIDC integration** with Google accounts
- **Auto-user creation** from Google authentication
- **SSO + password** hybrid authentication support
- **Local development** configured for `vault.local`

### 2. ✅ Username/Password Authentication  
- **Standard password management** for all users
- **Password policies** and complexity requirements
- **Password reset** via email (optional for local dev)
- **Emergency access** for account recovery

### 3. ✅ TOTP Add-on Support
- **Built-in TOTP** support (Google Authenticator, Authy, etc.)
- **WebAuthn/FIDO2** hardware security keys
- **Email 2FA** as backup method (with SMTP configured)
- **Recovery codes** for emergency access

### 4. ✅ Secure File Sharing
- **Bitwarden Send** for encrypted file sharing
- **Time-limited links** with expiration (7-31 days)
- **Password protection** for shared content
- **Access count limits** and self-destruct options
- **File upload** up to 100MB per file, 1GB per user

## 🏗️ Architecture

### Local Development
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx Proxy   │────│   Vaultwarden   │────│   PostgreSQL    │
│ (vault.local)   │    │   (Main App)    │    │   (Database)    │
│   SSL via       │    │                 │    │                 │
│    mkcert       │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Production
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx Proxy   │────│   Vaultwarden   │────│   PostgreSQL    │
│   (SSL/TLS)     │    │   (Main App)    │    │   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         └──────────────│     Certbot     │──────────────┘
                        │ (SSL Renewal)   │
                        └─────────────────┘
```

## 📁 File Structure

```
vaultwarden-setup/
├── 🍎 Mac/Linux Files
│   ├── deploy-mac.sh               # Mac deployment script
│   ├── local-ssl-setup.sh          # Mac SSL certificate setup
│   ├── mac-setup-prerequisites.md  # Mac prerequisites guide
│   └── docker-compose.local.yml    # Local development compose
│
├── 🪟 Windows Files
│   ├── deploy-windows.ps1          # Windows deployment script
│   ├── windows-ssl-setup.ps1       # Windows SSL certificate setup
│   ├── windows-setup-prerequisites.md # Windows prerequisites guide
│   └── nginx-local.conf            # Local Nginx configuration
│
├── 🌐 Production Files
│   ├── docker-compose.yml          # Production Docker Compose
│   ├── nginx.conf                  # Production Nginx config
│   ├── ssl-certificate-setup.sh    # Production SSL setup
│   └── nginx-with-certbot.conf     # Nginx with Certbot
│
├── ⚙️ Configuration
│   ├── .env.local                  # Local development template
│   ├── .env.example               # Production template
│   └── google-oauth-local-setup.md # OAuth for local dev
│
└── 📚 Documentation
    ├── google-oauth-setup.md       # Production OAuth setup
    ├── totp-mfa-setup.md          # TOTP/MFA configuration
    ├── bitwarden-send-setup.md    # File sharing setup
    ├── smtp-setup.md              # Email configuration
    └── README-COMPLETE.md         # This file
```

## 🛠️ Platform-Specific Commands

### Mac Commands
```bash
# Setup and deployment
./deploy-mac.sh setup      # Initial setup
./deploy-mac.sh start      # Start services
./deploy-mac.sh stop       # Stop services
./deploy-mac.sh restart    # Restart services
./deploy-mac.sh logs       # View logs
./deploy-mac.sh clean      # Clean up
./deploy-mac.sh token      # Generate admin token

# SSL certificates
./local-ssl-setup.sh       # Setup local SSL
```

### Windows Commands
```powershell
# Setup and deployment
.\deploy-windows.ps1 -Setup     # Initial setup
.\deploy-windows.ps1 -Start     # Start services
.\deploy-windows.ps1 -Stop      # Stop services
.\deploy-windows.ps1 -Restart   # Restart services
.\deploy-windows.ps1 -Logs      # View logs
.\deploy-windows.ps1 -Clean     # Clean up

# SSL certificates
.\windows-ssl-setup.ps1         # Setup local SSL

# Generate admin token
[System.Convert]::ToBase64String((1..48 | ForEach {Get-Random -Maximum 256}))
```

## 🔧 Configuration Guide

### Local Development (.env)
```bash
# Database
DB_PASSWORD=vaultwarden_local_dev_password_2024

# Admin Access (generate with platform script)
ADMIN_TOKEN=your_generated_admin_token_here

# Local Domain
DOMAIN=vault.local

# Google OAuth (from Google Cloud Console)
GOOGLE_CLIENT_ID=your_google_client_id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Optional: SMTP for email features
SMTP_HOST=smtp.gmail.com
SMTP_FROM=your-email@gmail.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your_app_password
```

### Google OAuth Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project: "Vaultwarden Local Dev"
3. Enable Google+ API and People API
4. Create OAuth 2.0 credentials:
   - **Authorized origins**: `https://vault.local`
   - **Redirect URIs**: `https://vault.local/identity/connect/oidc-signin`
5. Add credentials to `.env` file

## 🔐 First-Time Setup

### 1. Access Your Instance
- **URL**: `https://vault.local`
- **Admin Panel**: `https://vault.local/admin`

### 2. Admin Configuration
1. Enter your admin token
2. Configure organization settings
3. Set up user policies

### 3. Test All Features

#### ✅ Google Login:
- Click "Sign in with Google" on login page
- Authenticate with your Google account
- Verify user is created automatically

#### ✅ Username/Password:
- Create account with email/password
- Test login with credentials
- Try password reset (if SMTP configured)

#### ✅ TOTP/MFA:
- Login to web vault
- Go to Settings > Security > Two-step Login
- Set up authenticator app (Google Authenticator, Authy)
- Test login with TOTP code

#### ✅ Secure File Sharing:
- Navigate to "Send" tab in web vault
- Create new Send (text or file)
- Set expiration date and access limits
- Share generated link and test access

## 🔍 Troubleshooting

### Common Issues

#### Google OAuth Not Working
```bash
# Check redirect URIs match exactly
# Verify in Google Cloud Console:
# - Authorized origins: https://vault.local
# - Redirect URIs: https://vault.local/identity/connect/oidc-signin

# Check environment variables
grep GOOGLE .env

# View OAuth logs
docker logs vaultwarden | grep -i oauth
```

#### SSL Certificate Issues
```bash
# Mac: Reinstall certificates
./local-ssl-setup.sh

# Windows: Run as Administrator
.\windows-ssl-setup.ps1

# Verify certificate
openssl x509 -in ssl/cert.pem -text -noout
```

#### Services Not Starting
```bash
# Check Docker is running
docker ps

# Check logs for errors
# Mac:
./deploy-mac.sh logs

# Windows:
.\deploy-windows.ps1 -Logs
```

### Debug Commands

#### Mac/Linux
```bash
# Check service status
docker compose -f docker-compose.local.yml ps

# View specific service logs
docker logs vaultwarden
docker logs vaultwarden-db
docker logs vaultwarden-nginx

# Test connectivity
curl -k https://vault.local
```

#### Windows
```powershell
# Check service status
docker compose -f docker-compose.local.yml ps

# View specific service logs
docker logs vaultwarden
docker logs vaultwarden-db
docker logs vaultwarden-nginx

# Test connectivity
Invoke-WebRequest -Uri https://vault.local -SkipCertificateCheck
```

## 🚀 Production Deployment

For production deployment, see the original production files:
- `docker-compose.yml` - Production configuration
- `ssl-certificate-setup.sh` - Let's Encrypt SSL setup
- Replace `vault.local` with your actual domain
- Configure proper SMTP settings
- Set up proper backup strategies

## 🎉 Success!

Your Vaultwarden instance now provides:
- ✅ **Google OAuth login** - Single sign-on with Google accounts
- ✅ **Standard authentication** - Username/password login
- ✅ **TOTP/MFA security** - Multiple 2FA methods
- ✅ **Secure file sharing** - Bitwarden Send with encryption
- ✅ **Local development** - Works on both Mac and Windows
- ✅ **Production ready** - Scalable deployment options

**Local Access**: https://vault.local  
**Admin Panel**: https://vault.local/admin

**All 4 requirements fulfilled** - Your organization now has a complete, secure, open-source credential management platform!