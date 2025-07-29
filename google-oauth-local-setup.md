# Google OAuth Setup for Local Mac Development

## Overview
Setting up Google OAuth for local development requires specific configuration to work with `vault.local` domain.

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project:
   - Click "Select a project" → "New Project"
   - Project name: "Vaultwarden Local Development"
   - Click "Create"

## Step 2: Enable Required APIs

1. Go to "APIs & Services" → "Library"
2. Enable these APIs:
   - **Google+ API** (Legacy, but still needed)
   - **Google Identity and Access Management (IAM) API**
   - **People API** (for profile information)

## Step 3: Configure OAuth Consent Screen

1. Go to "APIs & Services" → "OAuth consent screen"
2. Choose **External** (unless you have Google Workspace)
3. Fill in required fields:
   ```
   App name: Vaultwarden Local Dev
   User support email: your-email@gmail.com
   Developer contact: your-email@gmail.com
   ```
4. **Scopes**: Add these scopes:
   - `../auth/userinfo.email`
   - `../auth/userinfo.profile`
   - `openid`
5. **Test users**: Add your Gmail account for testing

## Step 4: Create OAuth 2.0 Credentials

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth 2.0 Client IDs"
3. Application type: **Web application**
4. Name: "Vaultwarden Local"
5. **Authorized JavaScript origins**:
   ```
   https://vault.local
   ```
6. **Authorized redirect URIs**:
   ```
   https://vault.local/identity/connect/oidc-signin
   ```

## Step 5: Download Credentials

1. Click the download icon next to your OAuth client
2. Save the JSON file as `google-oauth-credentials.json`
3. Extract the values you need:
   ```json
   {
     "client_id": "your-client-id.apps.googleusercontent.com",
     "client_secret": "your-client-secret"
   }
   ```

## Step 6: Update Environment Variables

Add to your `.env.local` file:
```bash
# Google OAuth Configuration
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
```

## Troubleshooting

### Common Issues:

1. **"redirect_uri_mismatch" error**:
   - Ensure `https://vault.local/identity/connect/oidc-signin` is in authorized redirect URIs
   - Check that you're accessing via `https://vault.local` (not localhost)

2. **"This app isn't verified" warning**:
   - Normal for development, click "Advanced" → "Go to app (unsafe)"
   - For production, you'd need to verify the app

3. **SSL certificate issues**:
   - Make sure you've run the SSL setup script
   - Restart your browser after installing certificates

4. **OAuth not appearing in Vaultwarden**:
   - Check that all environment variables are set
   - Restart the Docker containers
   - Check logs: `docker logs vaultwarden`

## Testing OAuth Integration

1. Start Vaultwarden: `docker compose -f docker-compose.local.yml up -d`
2. Go to `https://vault.local`
3. You should see "Log in with Google" button
4. Click it and authenticate with your Google account
5. You should be automatically logged into Vaultwarden

## Security Notes for Local Development

- OAuth credentials are for development only
- Don't commit credentials to version control
- Use test Google accounts when possible
- The consent screen will show "unverified app" warnings