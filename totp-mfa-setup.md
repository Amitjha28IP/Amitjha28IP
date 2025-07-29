# TOTP/MFA Setup for Vaultwarden

## Overview
Vaultwarden supports multiple MFA methods out of the box:
- **TOTP (Time-based One-Time Password)** - Google Authenticator, Authy, etc.
- **WebAuthn/FIDO2** - Hardware security keys, biometrics
- **Duo** - Duo Security integration
- **Email** - Email-based 2FA codes

## Step 1: Enable MFA in Vaultwarden

MFA is already enabled in our Docker Compose configuration. The key settings are:

```yaml
environment:
  # MFA is enabled by default in Vaultwarden
  # These settings control MFA behavior:
  DISABLE_2FA_REMEMBER: false  # Allow "Remember this device"
  
  # Email 2FA settings (requires SMTP)
  EMAIL_2FA_AUTO_FALLBACK: true
  
  # Emergency access settings
  EMERGENCY_ACCESS_ALLOWED: true
```

## Step 2: Configure TOTP for Users

### For Admin (via Admin Panel):

1. Access admin panel: `https://vault.yourdomain.com/admin`
2. Login with your admin token
3. Navigate to "Users" section
4. For each user, you can:
   - View their 2FA status
   - Disable 2FA if needed (emergency)
   - Force 2FA requirement

### For End Users:

1. Login to Vaultwarden web vault
2. Go to "Settings" > "Security" > "Two-step Login"
3. Click "Manage" next to "Authenticator App (TOTP)"
4. Scan QR code with:
   - Google Authenticator
   - Authy
   - Microsoft Authenticator
   - Any TOTP-compatible app
5. Enter verification code to confirm setup

## Step 3: Configure WebAuthn/FIDO2 (Hardware Keys)

WebAuthn is automatically available and supports:
- YubiKey
- Windows Hello
- Touch ID/Face ID
- Google Titan Security Key
- Any FIDO2-compatible device

### User Setup:
1. Settings > Security > Two-step Login
2. Click "Manage" next to "FIDO2 WebAuthn"
3. Click "Add Security Key"
4. Follow browser prompts to register device

## Step 4: Configure Duo Integration (Optional)

If you have Duo Security:

```yaml
# Add to docker-compose.yml environment:
DUO_IKEY: "${DUO_INTEGRATION_KEY}"
DUO_SKEY: "${DUO_SECRET_KEY}"
DUO_AKEY: "${DUO_APPLICATION_KEY}"  # Generate: openssl rand -hex 40
DUO_HOST: "api-xxxxxxxx.duosecurity.com"
```

Add to `.env`:
```bash
DUO_INTEGRATION_KEY=your_duo_integration_key
DUO_SECRET_KEY=your_duo_secret_key
DUO_APPLICATION_KEY=your_generated_application_key
```

## Step 5: Enforce MFA Policies

### Organization-wide MFA Enforcement:

1. Admin Panel > Organizations
2. Select your organization
3. Go to "Policies" tab
4. Enable "Two-step login" policy
5. Set requirements:
   - Require for all users
   - Specific MFA methods only
   - Grace period for new users

### Via Environment Variables:

```yaml
# Force MFA for all users
REQUIRE_2FA: true

# Disable less secure MFA methods
DISABLE_EMAIL_2FA: false  # Set to true to disable email 2FA
```

## Step 6: Backup and Recovery Codes

### Enable Recovery Codes:
1. User Settings > Security > Two-step Login
2. Click "View Recovery Code"
3. Save the recovery code securely
4. Use recovery code if primary MFA is unavailable

### Admin Recovery:
Admins can disable MFA for users in emergency situations via the admin panel.

## Step 7: Test MFA Configuration

### Test Scenarios:
1. **TOTP Login**: Login with username/password + TOTP code
2. **WebAuthn Login**: Login with hardware key
3. **Recovery**: Use recovery code when TOTP unavailable
4. **Multiple Methods**: Register multiple MFA methods per user

### Testing Commands:
```bash
# Check MFA status in logs
docker logs vaultwarden | grep -i "2fa\|mfa\|totp"

# Test SMTP for email 2FA
docker exec vaultwarden /vaultwarden --help | grep -i smtp
```

## Security Best Practices

1. **Multiple MFA Methods**: Encourage users to register multiple methods
2. **Backup Codes**: Ensure users save recovery codes
3. **Hardware Keys**: Recommend FIDO2 keys for high-security users
4. **Regular Audits**: Monitor MFA adoption via admin panel
5. **Grace Periods**: Set reasonable grace periods for MFA enforcement

## Troubleshooting

### Common Issues:

1. **TOTP Time Sync**: Ensure server time is synchronized
   ```bash
   # Check server time
   docker exec vaultwarden date
   
   # Sync time if needed
   sudo ntpdate -s time.nist.gov
   ```

2. **WebAuthn Not Working**: 
   - Ensure HTTPS is properly configured
   - Check browser compatibility
   - Verify domain matches exactly

3. **Email 2FA Not Sending**:
   - Verify SMTP configuration
   - Check spam folders
   - Test SMTP settings

### Debug Commands:
```bash
# Enable debug logging for MFA
docker-compose down
# Edit docker-compose.yml to set LOG_LEVEL: debug
docker-compose up -d

# View detailed logs
docker logs -f vaultwarden
```