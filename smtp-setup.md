# SMTP Configuration for Vaultwarden

## Overview
SMTP is essential for:
- **User invitations** - Invite new users to your organization
- **Email 2FA** - Send 2FA codes via email
- **Password reset** - Allow users to reset forgotten passwords
- **Emergency access** - Notify users of emergency access requests
- **Organization notifications** - Admin and security notifications

## Step 1: Choose Email Provider

### Recommended Providers:

#### Gmail/Google Workspace
- **SMTP Server**: `smtp.gmail.com`
- **Port**: 587 (STARTTLS) or 465 (SSL)
- **Requires**: App Password (not regular password)

#### Microsoft 365/Outlook
- **SMTP Server**: `smtp-mail.outlook.com`
- **Port**: 587 (STARTTLS)
- **Requires**: App Password or OAuth2

#### SendGrid (Recommended for Production)
- **SMTP Server**: `smtp.sendgrid.net`
- **Port**: 587 or 465
- **Benefits**: High deliverability, detailed analytics

#### Amazon SES
- **SMTP Server**: `email-smtp.region.amazonaws.com`
- **Port**: 587 or 465
- **Benefits**: Cost-effective, AWS integration

#### Mailgun
- **SMTP Server**: `smtp.mailgun.org`
- **Port**: 587 or 465
- **Benefits**: Developer-friendly, good API

## Step 2: Gmail Setup (Most Common)

### Create App Password:
1. Go to [Google Account Settings](https://myaccount.google.com/)
2. Navigate to "Security" > "2-Step Verification"
3. Enable 2-Step Verification if not already enabled
4. Go to "App passwords"
5. Generate new app password for "Mail"
6. Copy the 16-character password

### Update .env file:
```bash
# Gmail SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_FROM=your-email@gmail.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-16-character-app-password
```

## Step 3: SendGrid Setup (Production Recommended)

### Create SendGrid Account:
1. Sign up at [SendGrid](https://sendgrid.com/)
2. Verify your account and domain
3. Create API Key with "Mail Send" permissions
4. Configure sender authentication

### Update .env file:
```bash
# SendGrid SMTP Configuration
SMTP_HOST=smtp.sendgrid.net
SMTP_FROM=noreply@yourdomain.com
SMTP_USERNAME=apikey
SMTP_PASSWORD=your-sendgrid-api-key
```

## Step 4: Advanced SMTP Configuration

### Additional Environment Variables:

```yaml
# Add to docker-compose.yml environment:
environment:
  # Basic SMTP settings (already configured)
  SMTP_HOST: ${SMTP_HOST}
  SMTP_FROM: ${SMTP_FROM}
  SMTP_PORT: 587
  SMTP_SECURITY: starttls  # or 'ssl' for port 465
  SMTP_USERNAME: ${SMTP_USERNAME}
  SMTP_PASSWORD: ${SMTP_PASSWORD}
  
  # Advanced SMTP settings
  SMTP_TIMEOUT: 15              # Connection timeout in seconds
  SMTP_FROM_NAME: "Vaultwarden Password Manager"  # Display name
  SMTP_DEBUG: false             # Enable SMTP debugging
  SMTP_ACCEPT_INVALID_CERTS: false  # Allow invalid SSL certificates
  SMTP_ACCEPT_INVALID_HOSTNAMES: false  # Allow invalid hostnames
  
  # Email template customization
  SMTP_EMBED_IMAGES: true       # Embed images in email templates
  
  # Rate limiting
  SMTP_MAX_POOL_SIZE: 10        # Maximum concurrent connections
```

### Custom Email Templates:

Create custom email templates by mounting them as volumes:

```yaml
# Add to docker-compose.yml volumes:
volumes:
  - ./email-templates:/data/templates:ro
```

## Step 5: Test SMTP Configuration

### Via Admin Panel:
1. Access admin panel: `https://vault.yourdomain.com/admin`
2. Go to "SMTP Settings" section
3. Click "Test SMTP" button
4. Check if test email is received

### Via Command Line:
```bash
# Test SMTP connection
docker exec vaultwarden /vaultwarden --test-smtp

# Send test email
docker exec vaultwarden /vaultwarden --send-test-email your-email@domain.com

# Check logs for SMTP activity
docker logs vaultwarden | grep -i smtp
```

### Manual Test:
```bash
# Test SMTP connection manually
docker exec -it vaultwarden sh

# Inside container, test with telnet
apk add telnet
telnet smtp.gmail.com 587
```

## Step 6: Email Templates and Customization

### Default Email Types:
- **Welcome Email** - New user registration
- **Invite Email** - Organization invitations
- **2FA Email** - Two-factor authentication codes
- **Password Reset** - Password reset links
- **Emergency Access** - Emergency access notifications

### Custom Templates Directory Structure:
```
email-templates/
├── invite_accepted.hbs
├── invite_confirmed.hbs
├── new_device_logged_in.hbs
├── pw_hint_none.hbs
├── pw_hint_some.hbs
├── send_2fa_removed_from_org.hbs
├── send_emergency_access_invite_accepted.hbs
├── send_emergency_access_invite_confirmed.hbs
├── send_emergency_access_recovery_approved.hbs
├── send_emergency_access_recovery_initiated.hbs
├── send_emergency_access_recovery_rejected.hbs
├── send_emergency_access_recovery_reminder.hbs
├── send_emergency_access_recovery_timed_out.hbs
├── send_invite.hbs
├── send_org_invite.hbs
├── send_single_org_removed_from_org.hbs
├── send_two_factor_email.hbs
├── send_verify_email.hbs
└── welcome_must_verify.hbs
```

### Example Custom Template (send_invite.hbs):
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Vaultwarden Invitation</title>
</head>
<body>
    <h2>You've been invited to join {{org_name}}</h2>
    <p>Hello,</p>
    <p>You have been invited to join the <strong>{{org_name}}</strong> organization in Vaultwarden.</p>
    <p><a href="{{url}}" style="background-color: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Accept Invitation</a></p>
    <p>If you have any questions, please contact your administrator.</p>
    <p>Best regards,<br>Your Vaultwarden Team</p>
</body>
</html>
```

## Step 7: Troubleshooting SMTP Issues

### Common Problems:

#### 1. Authentication Failed
```bash
# Check credentials
docker logs vaultwarden | grep -i "auth"

# Verify app password for Gmail
# Ensure 2FA is enabled before creating app password
```

#### 2. Connection Timeout
```bash
# Check firewall rules
sudo ufw status

# Test connectivity
docker exec vaultwarden telnet smtp.gmail.com 587

# Check DNS resolution
docker exec vaultwarden nslookup smtp.gmail.com
```

#### 3. TLS/SSL Issues
```bash
# Test with different security settings
# Try SMTP_SECURITY: 'ssl' instead of 'starttls'
# Or try port 465 instead of 587
```

#### 4. Rate Limiting
```bash
# Check for rate limit errors in logs
docker logs vaultwarden | grep -i "rate\|limit"

# Implement delays between emails
SMTP_MAX_POOL_SIZE: 5  # Reduce concurrent connections
```

### Debug Commands:
```bash
# Enable SMTP debugging
# Set SMTP_DEBUG: true in docker-compose.yml

# View detailed SMTP logs
docker logs -f vaultwarden | grep -i smtp

# Test specific SMTP settings
docker exec vaultwarden env | grep SMTP
```

## Step 8: Production SMTP Best Practices

### Security:
1. **Use App Passwords**: Never use main account passwords
2. **Secure Credentials**: Store SMTP credentials in .env file
3. **TLS Encryption**: Always use STARTTLS or SSL
4. **Restrict Access**: Limit SMTP credentials to mail sending only

### Deliverability:
1. **SPF Records**: Configure SPF for your domain
   ```
   v=spf1 include:_spf.google.com ~all
   ```

2. **DKIM Signing**: Enable DKIM in your email provider
3. **DMARC Policy**: Set up DMARC for your domain
   ```
   v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com
   ```

4. **Reverse DNS**: Ensure proper PTR records

### Monitoring:
1. **Log Monitoring**: Monitor SMTP logs for failures
2. **Bounce Handling**: Monitor for bounced emails
3. **Rate Limiting**: Respect provider rate limits
4. **Health Checks**: Regular SMTP connectivity tests

## Step 9: Alternative Email Services

### Self-Hosted Options:

#### Postfix + Dovecot
```yaml
# Add to docker-compose.yml
mailserver:
  image: mailserver/docker-mailserver:latest
  container_name: mailserver
  hostname: mail.yourdomain.com
  ports:
    - "25:25"
    - "587:587"
    - "993:993"
  volumes:
    - ./mail-data:/var/mail
    - ./mail-config:/tmp/docker-mailserver
  environment:
    - ENABLE_SPAMASSASSIN=1
    - ENABLE_CLAMAV=1
    - SSL_TYPE=letsencrypt
```

#### Mailu
```yaml
# Mailu email server
mailu:
  image: mailu/admin:latest
  restart: always
  env_file: mailu.env
  ports:
    - "80:80"
    - "443:443"
    - "25:25"
    - "587:587"
```

### Cloud Services Comparison:

| Provider | Free Tier | Cost | Deliverability | Ease of Setup |
|----------|-----------|------|----------------|---------------|
| Gmail | 100/day | Free | Good | Easy |
| SendGrid | 100/day | $14.95/mo | Excellent | Medium |
| Amazon SES | 62,000/mo | $0.10/1000 | Excellent | Hard |
| Mailgun | 5,000/mo | $35/mo | Excellent | Medium |
| Postmark | 100/mo | $10/mo | Excellent | Easy |

## Step 10: Monitoring and Maintenance

### Log Analysis:
```bash
# Monitor email sending
docker logs vaultwarden | grep -i "email\|smtp" | tail -20

# Check for failed deliveries
docker logs vaultwarden | grep -i "failed\|error" | grep -i "email"

# Monitor invitation emails
docker logs vaultwarden | grep -i "invite"
```

### Health Check Script:
```bash
#!/bin/bash
# smtp-health-check.sh

SMTP_TEST_EMAIL="admin@yourdomain.com"

# Test SMTP connectivity
if docker exec vaultwarden /vaultwarden --test-smtp > /dev/null 2>&1; then
    echo "✅ SMTP connectivity: OK"
else
    echo "❌ SMTP connectivity: FAILED"
    # Send alert or restart service
fi

# Send test email monthly
if [ "$(date +%d)" = "01" ]; then
    docker exec vaultwarden /vaultwarden --send-test-email "$SMTP_TEST_EMAIL"
    echo "📧 Monthly test email sent"
fi
```

### Automated Monitoring:
```bash
# Add to crontab for daily checks
0 9 * * * /path/to/smtp-health-check.sh >> /var/log/vaultwarden-smtp.log 2>&1
```