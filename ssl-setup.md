version: '3.8'

services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    environment:
      # Basic Configuration
      DOMAIN: "https://vault.yourdomain.com"
      
      # Database Configuration
      DATABASE_URL: postgresql://vaultwarden:${DB_PASSWORD}@db:5432/vaultwarden
      
      # Admin Configuration
      ADMIN_TOKEN: ${ADMIN_TOKEN}
      
      # Email Configuration
      SMTP_HOST: ${SMTP_HOST}
      SMTP_FROM: ${SMTP_FROM}
      SMTP_PORT: 587
      SMTP_SECURITY: starttls
      SMTP_USERNAME: ${SMTP_USERNAME}
      SMTP_PASSWORD: ${SMTP_PASSWORD}
      
      # Security Settings
      SIGNUPS_ALLOWED: false
      INVITATIONS_ALLOWED: true
      EMERGENCY_ACCESS_ALLOWED: true
      SENDS_ALLOWED: true
      WEB_VAULT_ENABLED: true
      
      # Password Policy
      PASSWORD_ITERATIONS: 600000
      
      # File Upload Limits
      ATTACHMENT_LIMIT: 104857600
      USER_ATTACHMENT_LIMIT: 1073741824
      
      # Logging
      LOG_LEVEL: warn
      EXTENDED_LOGGING: true
      
      # Google OAuth/OIDC Configuration
      SSO_ENABLED: true
      SSO_ONLY: false
      OIDC_ENABLED: true
      OIDC_ISSUER: "https://accounts.google.com"
      OIDC_CLIENT_ID: "${GOOGLE_CLIENT_ID}"
      OIDC_CLIENT_SECRET: "${GOOGLE_CLIENT_SECRET}"
      OIDC_SCOPES: "openid email profile"
      OIDC_REDIRECT_URI: "https://vault.yourdomain.com/identity/connect/oidc-signin"
      OIDC_AUTO_CREATE_USERS: true
      OIDC_EMAIL_CLAIM: "email"
      OIDC_NAME_CLAIM: "name"
      
      # MFA/2FA Configuration
      DISABLE_2FA_REMEMBER: false
      EMAIL_2FA_AUTO_FALLBACK: true
      
      # Bitwarden Send Configuration
      SEND_PURGE_SCHEDULE: "0 5 * * * *"
      SEND_DEFAULT_DELETE_DAYS: 7
      SEND_MAX_DELETE_DAYS: 31
      SEND_MAX_ACCESS_COUNT: 100
      
    volumes:
      - vw_data:/data
    depends_on:
      - db
    networks:
      - vaultwarden

  db:
    image: postgres:15
    container_name: vaultwarden_db
    restart: unless-stopped
    environment:
      POSTGRES_DB: vaultwarden
      POSTGRES_USER: vaultwarden
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - vaultwarden

  nginx:
    image: nginx:alpine
    container_name: vaultwarden_nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - certbot_certs:/etc/letsencrypt:ro
      - certbot_www:/var/www/certbot:ro
      - nginx_logs:/var/log/nginx
    depends_on:
      - vaultwarden
    networks:
      - vaultwarden
    command: '/bin/sh -c ''while :; do sleep 6h & wait $${!}; nginx -s reload; done & nginx -g "daemon off;"'''

  certbot:
    image: certbot/certbot
    container_name: vaultwarden_certbot
    restart: unless-stopped
    volumes:
      - certbot_certs:/etc/letsencrypt
      - certbot_www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"

volumes:
  vw_data:
  db_data:
  nginx_logs:
  certbot_certs:
  certbot_www:

networks:
  vaultwarden:
    driver: bridge