# Vaultwarden Complete Setup

A production-ready Vaultwarden deployment with **all your requirements**:

✅ **Google Login Support** - OAuth2/OIDC integration  
✅ **Username/Password** - Standard password management  
✅ **TOTP Add-on** - Built-in TOTP/MFA support  
✅ **Secure File Sharing** - Bitwarden Send for encrypted file sharing  

## 🚀 Quick Start

1. **Clone and Configure**
   ```bash
   git clone <your-repo> vaultwarden-setup
   cd vaultwarden-setup
   
   # Copy and edit environment file
   cp .env.example .env
   nano .env
   ```

2. **Update Configuration**
   - Replace `vault.yourdomain.com` with your actual domain
   - Configure SMTP settings in `.env`
   - Set secure passwords and tokens

3. **Set up SSL and Deploy**
   ```bash
   # Make setup script executable
   chmod +x ssl-certificate-setup.sh
   
   # Edit script with your domain and email
   nano ssl-certificate-setup.sh
   
   # Run automated setup
   ./ssl-certificate-setup.sh
   ```

## 📋 Requirements Met

### 1. ✅ Google Login Support
- **OAuth2/OIDC integration** with Google accounts
- **Auto-user creation** from Google authentication
- **SSO + password** hybrid authentication support
- **Configuration**: See `google-oauth-setup.md`

### 2. ✅ Username/Password Authentication  
- **Standard password management** for all users
- **Password policies** and complexity requirements
- **Password reset** via email
- **Emergency access** for account recovery

### 3. ✅ TOTP Add-on Support
- **Built-in TOTP** support (Google Authenticator, Authy, etc.)
- **WebAuthn/FIDO2** hardware security keys
- **Email 2FA** as backup method
- **Recovery codes** for emergency access
- **Configuration**: See `totp-mfa-setup.md`

### 4. ✅ Secure File Sharing
- **Bitwarden Send** for encrypted file sharing
- **Time-limited links** with expiration
- **Password protection** for shared content
- **Access count limits** and self-destruct options
- **File upload** up to 100MB per file, 1GB per user
- **Configuration**: See `bitwarden-send-setup.md`

## 🏗️ Architecture

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
├── docker-compose.yml          # Main Docker Compose configuration
├── ssl-setup.md               # Alternative with Certbot integration
├── nginx.conf                 # Nginx reverse proxy config
├── nginx-with-certbot.conf    # Nginx config for SSL automation
├── .env                       # Environment variables (copy from .env.example)
├── ssl-certificate-setup.sh   # Automated SSL setup script
├── google-oauth-setup.md      # Google OAuth configuration guide
├── totp-mfa-setup.md         # TOTP/MFA configuration guide
├── bitwarden-send-setup.md   # Secure file sharing setup
├── smtp-setup.md             # Email configuration guide
└── README.md                 # This file
```

## ⚙️ Configuration

### Environment Variables (.env)

```bash
# Database
DB_PASSWORD=your_secure_database_password

# Admin Access
ADMIN_TOKEN=your_admin_token_here

# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_FROM=your-email@yourdomain.com
SMTP_USERNAME=your-email@yourdomain.com
SMTP_PASSWORD=your_app_password

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Domain
DOMAIN=vault.yourdomain.com
```

### Key Features Enabled

- **Google OAuth/OIDC**: Automatic user creation from Google accounts
- **TOTP/MFA**: Multiple 2FA methods (TOTP, WebAuthn, Email)
- **Bitwarden Send**: Secure file and text sharing with expiration
- **Email Integration**: SMTP for invitations, 2FA, and notifications
- **SSL/TLS**: Automated certificate management with Let's Encrypt
- **Security Headers**: Modern security headers and CSP
- **Database**: PostgreSQL for production reliability

## 🔧 Deployment Steps

### 1. Prerequisites
- Docker and Docker Compose installed
- Domain name pointing to your server
- Ports 80 and 443 open
- Email provider for SMTP (Gmail recommended for testing)

### 2. Configuration
```bash
# 1. Configure environment
cp .env.example .env
nano .env  # Update all values

# 2. Update domain in configs
sed -i 's/vault\.yourdomain\.com/your-actual-domain.com/g' *.conf *.md
```

### 3. Google OAuth Setup
1. Follow instructions in `google-oauth-setup.md`
2. Create OAuth application in Google Cloud Console
3. Add credentials to `.env` file

### 4. SSL Certificate Setup
```bash
# Edit setup script with your details
nano ssl-certificate-setup.sh

# Run automated setup
./ssl-certificate-setup.sh
```

### 5. Verify Deployment
```bash
# Check all services are running
docker-compose ps

# View logs
docker-compose logs -f

# Test access
curl -I https://your-domain.com
```

## 🔐 First-Time Setup

### 1. Admin Access
1. Navigate to `https://your-domain.com/admin`
2. Enter your admin token
3. Create your first organization
4. Configure organization policies

### 2. User Setup
1. **Google Login**: Users can sign in with Google accounts
2. **Regular Login**: Create accounts with username/password
3. **TOTP Setup**: Users configure 2FA in Settings > Security
4. **File Sharing**: Access "Send" tab for secure sharing

### 3. Test All Features

#### Google Login:
- Visit your Vaultwarden instance
- Click "Sign in with Google"
- Verify user is created automatically

#### TOTP/MFA:
- Login to web vault
- Go to Settings > Security > Two-step Login
- Set up authenticator app
- Test login with TOTP code

#### Secure File Sharing:
- Navigate to "Send" tab
- Create new Send (text or file)
- Set expiration and access limits
- Share generated link

## 📊 Monitoring

### Health Checks
```bash
# Check service status
docker-compose ps

# Monitor logs
docker-compose logs -f vaultwarden

# Check SSL certificate
openssl s_client -connect your-domain.com:443 -servername your-domain.com

# Test SMTP
docker exec vaultwarden /vaultwarden --test-smtp
```

### Backup Strategy
```bash
# Database backup
docker exec vaultwarden_db pg_dump -U vaultwarden vaultwarden > backup.sql

# Data backup
docker run --rm -v vaultwarden_vw_data:/data -v $(pwd):/backup alpine \
  tar czf /backup/vaultwarden-data-$(date +%Y%m%d).tar.gz -C /data .
```

## 🛠️ Maintenance

### Updates
```bash
# Update Vaultwarden
docker-compose pull
docker-compose up -d

# Update web vault (if needed)
docker-compose restart vaultwarden
```

### Certificate Renewal
Certificates auto-renew via Certbot. Manual renewal:
```bash
docker-compose run --rm certbot renew
docker-compose exec nginx nginx -s reload
```

### Log Rotation
```bash
# Set up log rotation
echo '/var/lib/docker/containers/*/*.log {
  daily
  rotate 7
  compress
  size 100M
  copytruncate
}' | sudo tee /etc/logrotate.d/docker
```

## 🔍 Troubleshooting

### Common Issues

1. **Google OAuth not working**:
   - Check redirect URIs in Google Console
   - Verify client ID and secret in `.env`
   - Ensure HTTPS is working

2. **TOTP codes not working**:
   - Check server time synchronization
   - Verify TOTP app time is correct
   - Use recovery codes if needed

3. **File uploads failing**:
   - Check nginx `client_max_body_size`
   - Verify disk space
   - Review file size limits

4. **Email not sending**:
   - Test SMTP configuration
   - Check app password for Gmail
   - Review SMTP logs

### Debug Commands
```bash
# Enable debug logging
# Edit docker-compose.yml: LOG_LEVEL: debug

# View specific logs
docker logs vaultwarden | grep -i "oauth\|smtp\|send"

# Test connectivity
docker exec vaultwarden curl -I https://accounts.google.com
```

## 📚 Documentation

- **Google OAuth**: `google-oauth-setup.md`
- **TOTP/MFA**: `totp-mfa-setup.md`
- **File Sharing**: `bitwarden-send-setup.md`
- **SMTP Config**: `smtp-setup.md`
- **SSL Setup**: `ssl-setup.md`

## 🆘 Support

For issues:
1. Check the troubleshooting section
2. Review logs: `docker-compose logs -f`
3. Verify configuration files
4. Check Vaultwarden wiki: https://github.com/dani-garcia/vaultwarden/wiki

## 🎉 Success!

Your Vaultwarden instance now provides:
- ✅ Google OAuth login
- ✅ Standard username/password authentication  
- ✅ TOTP/MFA security
- ✅ Secure file sharing with Bitwarden Send
- ✅ Production-ready SSL/TLS
- ✅ Email notifications and 2FA
- ✅ Complete credential management for your organization

**Access your instance**: https://your-domain.com  
**Admin panel**: https://your-domain.com/admin
