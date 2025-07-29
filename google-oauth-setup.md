# Google OAuth Setup for Vaultwarden

## Step 1: Create Google OAuth Application

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google+ API:
   - Go to "APIs & Services" > "Library"
   - Search for "Google+ API" and enable it
   - Also enable "Google Identity and Access Management (IAM) API"

## Step 2: Create OAuth 2.0 Credentials

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client IDs"
3. Configure the OAuth consent screen:
   - User Type: Internal (for organization) or External (for public)
   - App name: "Vaultwarden Password Manager"
   - User support email: your-email@yourdomain.com
   - Developer contact information: your-email@yourdomain.com

4. Create OAuth 2.0 Client ID:
   - Application type: Web application
   - Name: Vaultwarden
   - Authorized JavaScript origins:
     - https://vault.yourdomain.com
   - Authorized redirect URIs:
     - https://vault.yourdomain.com/identity/connect/oidc-signin
     - https://vault.yourdomain.com/sso-connector/oidc/callback

## Step 3: Configure Vaultwarden for Google OAuth

Update your Docker Compose file to include Google OAuth settings:

```yaml
# Add these environment variables to the vaultwarden service
environment:
  # ... existing environment variables ...
  
  # Google OAuth Configuration
  SSO_ENABLED: true
  SSO_ONLY: false  # Allow both SSO and regular login
  
  # OIDC Configuration for Google
  OIDC_ENABLED: true
  OIDC_ISSUER: "https://accounts.google.com"
  OIDC_CLIENT_ID: "${GOOGLE_CLIENT_ID}"
  OIDC_CLIENT_SECRET: "${GOOGLE_CLIENT_SECRET}"
  OIDC_SCOPES: "openid email profile"
  OIDC_REDIRECT_URI: "https://vault.yourdomain.com/identity/connect/oidc-signin"
  
  # Optional: Auto-create users from Google OAuth
  OIDC_AUTO_CREATE_USERS: true
  OIDC_EMAIL_CLAIM: "email"
  OIDC_NAME_CLAIM: "name"
```

## Step 4: Update Environment Variables

Add to your `.env` file:
```bash
# Replace with your actual Google OAuth credentials
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret
```

## Step 5: Test Google OAuth

1. Restart your Vaultwarden container
2. Navigate to https://vault.yourdomain.com
3. You should see a "Sign in with Google" option
4. Test the login flow

## Troubleshooting

### Common Issues:

1. **Redirect URI mismatch**: Ensure the redirect URI in Google Console matches exactly
2. **Domain verification**: Make sure your domain is verified in Google Console
3. **API not enabled**: Ensure Google+ API and IAM API are enabled
4. **Consent screen**: Complete the OAuth consent screen configuration

### Logs to check:
```bash
docker logs vaultwarden
```

Look for OAuth-related error messages and adjust configuration accordingly.