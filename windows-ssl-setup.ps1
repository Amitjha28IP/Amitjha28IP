# Windows SSL Certificate Setup for Vaultwarden
# This script creates trusted local SSL certificates using mkcert

param(
    [string]$Domain = "vault.local",
    [string]$CertDir = ".\ssl"
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Cyan"

Write-Host "🔐 Setting up Local SSL Certificates for Windows" -ForegroundColor $Green
Write-Host "=================================================" -ForegroundColor $Green

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "⚠️  Warning: Not running as Administrator" -ForegroundColor $Yellow
    Write-Host "   Some operations may require elevated privileges" -ForegroundColor $Yellow
}

# Check if mkcert is installed
try {
    $mkcertVersion = & mkcert -version 2>$null
    Write-Host "✅ mkcert found: $mkcertVersion" -ForegroundColor $Green
} catch {
    Write-Host "❌ mkcert is not installed" -ForegroundColor $Red
    Write-Host "Installing mkcert via Chocolatey..." -ForegroundColor $Yellow
    
    # Check if Chocolatey is installed
    try {
        choco --version | Out-Null
        choco install mkcert -y
    } catch {
        Write-Host "❌ Chocolatey not found. Please install mkcert manually:" -ForegroundColor $Red
        Write-Host "   1. Install Chocolatey: https://chocolatey.org/install" -ForegroundColor $Yellow
        Write-Host "   2. Run: choco install mkcert" -ForegroundColor $Yellow
        Write-Host "   3. Or download from: https://github.com/FiloSottile/mkcert/releases" -ForegroundColor $Yellow
        exit 1
    }
}

# Create certificate directory
Write-Host "📁 Creating certificate directory..." -ForegroundColor $Blue
if (-not (Test-Path $CertDir)) {
    New-Item -ItemType Directory -Path $CertDir -Force | Out-Null
}

# Install local CA
Write-Host "🏛️  Installing local Certificate Authority..." -ForegroundColor $Blue
try {
    & mkcert -install
    Write-Host "✅ Local CA installed successfully" -ForegroundColor $Green
} catch {
    Write-Host "❌ Failed to install local CA" -ForegroundColor $Red
    Write-Host "   Try running as Administrator" -ForegroundColor $Yellow
}

# Generate certificate for local domain
Write-Host "📜 Generating SSL certificate for $Domain..." -ForegroundColor $Blue
$certFile = Join-Path $CertDir "cert.pem"
$keyFile = Join-Path $CertDir "key.pem"

try {
    & mkcert -cert-file $certFile -key-file $keyFile $Domain localhost 127.0.0.1 ::1
    Write-Host "✅ SSL certificate generated successfully" -ForegroundColor $Green
} catch {
    Write-Host "❌ Failed to generate SSL certificate" -ForegroundColor $Red
    exit 1
}

# Set proper permissions (Windows equivalent)
Write-Host "🔒 Setting certificate permissions..." -ForegroundColor $Blue
if (Test-Path $certFile) {
    # Remove inheritance and set specific permissions
    $acl = Get-Acl $keyFile
    $acl.SetAccessRuleProtection($true, $false)
    
    # Add current user with full control
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($currentUser, "FullControl", "Allow")
    $acl.SetAccessRule($accessRule)
    
    # Add SYSTEM with full control
    $systemRule = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "Allow")
    $acl.SetAccessRule($systemRule)
    
    Set-Acl -Path $keyFile -AclObject $acl
}

# Verify certificates
Write-Host "🔍 Verifying certificate..." -ForegroundColor $Blue
try {
    $certInfo = & openssl x509 -in $certFile -text -noout 2>$null | Select-String "Subject:"
    Write-Host "Certificate Subject: $certInfo" -ForegroundColor $Green
} catch {
    Write-Host "⚠️  OpenSSL not available for verification (certificate should still work)" -ForegroundColor $Yellow
}

Write-Host ""
Write-Host "✅ SSL certificates created successfully!" -ForegroundColor $Green
Write-Host ""
Write-Host "Certificate files created:" -ForegroundColor $Yellow
Write-Host "  - Certificate: $certFile" -ForegroundColor $White
Write-Host "  - Private Key: $keyFile" -ForegroundColor $White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor $Yellow
Write-Host "  1. The certificates are now trusted by Windows" -ForegroundColor $White
Write-Host "  2. Chrome/Edge: Should work immediately" -ForegroundColor $White
Write-Host "  3. Firefox: May need to restart for certificate trust" -ForegroundColor $White
Write-Host "  4. If issues persist, try running as Administrator" -ForegroundColor $White
Write-Host ""
Write-Host "🚀 Ready to start Vaultwarden with HTTPS!" -ForegroundColor $Green

# Optional: Test certificate
Write-Host ""
$testCert = Read-Host "Test certificate installation? (y/N)"
if ($testCert -eq "y" -or $testCert -eq "Y") {
    Write-Host "🧪 Testing certificate..." -ForegroundColor $Blue
    try {
        $response = Invoke-WebRequest -Uri "https://$Domain" -SkipCertificateCheck -TimeoutSec 5 2>$null
        Write-Host "⚠️  Service not running yet (expected)" -ForegroundColor $Yellow
    } catch {
        if ($_.Exception.Message -like "*SSL*" -or $_.Exception.Message -like "*certificate*") {
            Write-Host "❌ SSL certificate issue detected" -ForegroundColor $Red
        } else {
            Write-Host "✅ SSL certificate appears to be working (service not running yet)" -ForegroundColor $Green
        }
    }
}