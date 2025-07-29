# Bitwarden Send - Secure File Sharing Setup

## Overview
Bitwarden Send allows users to securely share:
- **Text/Notes** - Passwords, secure notes, credentials
- **Files** - Documents, images, certificates (up to configured limits)
- **Encrypted Links** - Time-limited, password-protected, self-destructing

## Step 1: Enable Bitwarden Send

Bitwarden Send is already enabled in our Docker Compose configuration:

```yaml
environment:
  # Enable Bitwarden Send
  SENDS_ALLOWED: true
  
  # File upload limits
  ATTACHMENT_LIMIT: 104857600      # 100MB per file
  USER_ATTACHMENT_LIMIT: 1073741824  # 1GB total per user
  
  # Optional: Disable Send for specific users/orgs
  # SENDS_ALLOWED: false  # Globally disable
```

## Step 2: Configure Send Policies

### Global Send Configuration:

```yaml
# Add to docker-compose.yml environment:
environment:
  # Send expiration limits
  SEND_PURGE_SCHEDULE: "0 5 * * * *"  # Purge expired sends every hour at 5 minutes
  
  # Default Send settings
  SEND_DEFAULT_DELETE_DAYS: 7      # Default expiration: 7 days
  SEND_MAX_DELETE_DAYS: 31         # Maximum expiration: 31 days
  
  # Send access limits
  SEND_MAX_ACCESS_COUNT: 100       # Maximum access count per Send
  
  # File type restrictions (optional)
  SEND_ALLOWED_FILE_TYPES: "pdf,doc,docx,txt,jpg,png,zip"  # Comma-separated
```

### Organization Policies:

Admins can set organization-wide Send policies:
1. Admin Panel > Organizations > [Your Org] > Policies
2. Configure "Send Options" policy:
   - Disable Send for organization
   - Disable hiding email address
   - Disable Send password option

## Step 3: Using Bitwarden Send

### Via Web Vault:

1. Login to `https://vault.yourdomain.com`
2. Navigate to "Send" tab in left sidebar
3. Click "New Send"
4. Choose type:
   - **Text Send**: For passwords, notes, credentials
   - **File Send**: For documents, images, files

### Text Send Configuration:
- **Name**: Description of the Send
- **Text**: The secret text/password to share
- **Options**:
  - Expiration date/time
  - Maximum access count
  - Password protection
  - Hide email address
  - Deactivation date
  - Notes for recipient

### File Send Configuration:
- **Name**: Description of the Send
- **File**: Upload file (respects size limits)
- **Options**: Same as Text Send

### Send Link Generation:
After creating a Send, you get a secure link like:
`https://vault.yourdomain.com/#/send/abc123def456/key789`

## Step 4: Send Security Features

### Password Protection:
- Optional password required to access Send
- Password is not stored with the Send
- Recipient needs both link AND password

### Access Controls:
- **Max Access Count**: Limit how many times Send can be accessed
- **Expiration Date**: Automatic deletion after specified time
- **Deactivation Date**: Disable access before expiration

### Privacy Features:
- **Hide Email**: Don't show sender's email to recipient
- **Self-Destruct**: Send deleted after first access (set max access to 1)

## Step 5: Send Management

### For Users:
1. **View Active Sends**: Send tab shows all active Sends
2. **Edit Sends**: Modify expiration, access count, etc.
3. **Delete Sends**: Manually delete before expiration
4. **Send History**: View access logs and statistics

### For Admins:
1. **Monitor Sends**: Admin panel shows Send usage statistics
2. **Policy Enforcement**: Set organization-wide Send restrictions
3. **User Management**: Disable Send for specific users
4. **Storage Monitoring**: Track file storage usage

## Step 6: API Integration

### Send API Endpoints:
```bash
# Create Text Send
curl -X POST "https://vault.yourdomain.com/api/sends" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": 0,
    "name": "Secure Password Share",
    "text": {
      "text": "MySecretPassword123"
    },
    "maxAccessCount": 1,
    "deletionDate": "2024-12-31T23:59:59Z"
  }'

# Create File Send
curl -X POST "https://vault.yourdomain.com/api/sends/file" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "data={\"name\":\"Secure Document\",\"type\":1}" \
  -F "file=@document.pdf"
```

### CLI Integration:
```bash
# Install Bitwarden CLI
npm install -g @bitwarden/cli

# Login and create Send
bw login
bw send create --text "Secret message" --name "My Send"
bw send create --file document.pdf --name "Document Send"
```

## Step 7: Security Best Practices

### For Administrators:
1. **Set Reasonable Limits**: Configure appropriate file size and expiration limits
2. **Monitor Usage**: Regularly check Send usage statistics
3. **Policy Enforcement**: Use organization policies to control Send features
4. **Storage Management**: Monitor disk usage for file attachments

### For Users:
1. **Short Expiration**: Use shortest practical expiration time
2. **Limited Access**: Set low max access counts when possible
3. **Password Protection**: Use passwords for sensitive Sends
4. **Verify Recipients**: Ensure you're sharing with intended recipients
5. **Delete Early**: Manually delete Sends when no longer needed

## Step 8: Monitoring and Maintenance

### Log Monitoring:
```bash
# Monitor Send activity
docker logs vaultwarden | grep -i "send"

# Check file storage usage
docker exec vaultwarden du -sh /data/attachments/
```

### Cleanup Tasks:
```bash
# Manual cleanup of expired Sends (automatic with SEND_PURGE_SCHEDULE)
docker exec vaultwarden /vaultwarden --purge-sends

# Check database size
docker exec vaultwarden_db psql -U vaultwarden -d vaultwarden -c "
  SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
  FROM pg_tables 
  WHERE schemaname = 'public' 
  ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;"
```

## Step 9: Troubleshooting

### Common Issues:

1. **File Upload Fails**:
   - Check file size against limits
   - Verify disk space on server
   - Check nginx client_max_body_size

2. **Send Link Not Working**:
   - Verify HTTPS configuration
   - Check expiration date
   - Confirm access count not exceeded

3. **Slow File Uploads**:
   - Check network connectivity
   - Verify server resources
   - Consider increasing timeout values

### Debug Commands:
```bash
# Check Send configuration
docker exec vaultwarden printenv | grep -i send

# Monitor file uploads
docker logs -f vaultwarden | grep -i "upload\|attachment"

# Check storage usage
docker exec vaultwarden df -h /data/
```

## Step 10: Integration Examples

### Automated Send Creation (Script):
```bash
#!/bin/bash
# create-send.sh - Automated Send creation

API_URL="https://vault.yourdomain.com/api"
ACCESS_TOKEN="your_access_token"

# Create text Send
curl -X POST "$API_URL/sends" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": 0,
    "name": "Automated Password Share",
    "text": {"text": "'$1'"},
    "maxAccessCount": 1,
    "deletionDate": "'$(date -d "+1 day" -Iseconds)'"
  }' | jq -r '.accessId'
```

### Workflow Integration:
- **CI/CD**: Share deployment credentials securely
- **Support**: Share temporary access credentials with users
- **Compliance**: Secure document sharing with audit trails