# Windows Prerequisites for Vaultwarden Local Setup

## Required Software

### 1. Install Docker Desktop for Windows
```powershell
# Option 1: Download from Docker website
# Go to: https://www.docker.com/products/docker-desktop/

# Option 2: Install via Winget (Windows Package Manager)
winget install Docker.DockerDesktop

# Option 3: Install via Chocolatey
choco install docker-desktop
```

### 2. Install Windows Subsystem for Linux (WSL2) - Recommended
```powershell
# Enable WSL2 (run as Administrator)
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart Windows, then set WSL2 as default
wsl --set-default-version 2

# Install Ubuntu (recommended)
wsl --install -d Ubuntu
```

### 3. Install Git for Windows
```powershell
# Option 1: Download from git-scm.com
# Option 2: Via Winget
winget install Git.Git

# Option 3: Via Chocolatey
choco install git
```

### 4. Install OpenSSL for Windows
```powershell
# Via Chocolatey (recommended)
choco install openssl

# Or download from: https://slproweb.com/products/Win32OpenSSL.html
```

### 5. Install mkcert for Local SSL
```powershell
# Via Chocolatey
choco install mkcert

# Via Scoop
scoop install mkcert

# Or download from: https://github.com/FiloSottile/mkcert/releases
```

## System Configuration

### 1. Docker Desktop Settings
After installing Docker Desktop:
1. Open Docker Desktop
2. Go to Settings → General
   - ✅ Use WSL 2 based engine (recommended)
   - ✅ Start Docker Desktop when you log in
3. Go to Settings → Resources → WSL Integration
   - ✅ Enable integration with my default WSL distro
   - ✅ Enable integration with additional distros (Ubuntu)
4. Go to Settings → Resources → Advanced
   - **Memory**: 4GB minimum (8GB recommended)
   - **CPUs**: 2 minimum (4 recommended)
   - **Disk**: 20GB minimum

### 2. Windows Firewall Configuration
```powershell
# Run as Administrator
# Allow Docker through Windows Firewall
New-NetFirewallRule -DisplayName "Docker Desktop" -Direction Inbound -Protocol TCP -LocalPort 80,443,3012,8080 -Action Allow
New-NetFirewallRule -DisplayName "Docker Desktop" -Direction Outbound -Protocol TCP -LocalPort 80,443,3012,8080 -Action Allow
```

## Network Configuration

### 1. Local Domain Setup
Configure `vault.local` as local domain:

**Method 1: Edit hosts file manually**
```powershell
# Run as Administrator
notepad C:\Windows\System32\drivers\etc\hosts

# Add this line:
127.0.0.1    vault.local
```

**Method 2: PowerShell script (run as Administrator)**
```powershell
# Add entry to hosts file
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$domain = "127.0.0.1    vault.local"

# Check if entry already exists
$exists = Get-Content $hostsFile | Select-String "vault.local"
if (-not $exists) {
    Add-Content -Path $hostsFile -Value $domain
    Write-Host "Added vault.local to hosts file"
} else {
    Write-Host "vault.local already exists in hosts file"
}
```

### 2. DNS Configuration (Optional)
```powershell
# Flush DNS cache after hosts file changes
ipconfig /flushdns
```

## PowerShell Execution Policy
```powershell
# Allow script execution (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Verification

### Test Docker Installation
```powershell
# Test Docker
docker run hello-world

# Test Docker Compose
docker compose version

# Check WSL integration
wsl docker --version
```

### Test Network Configuration
```powershell
# Test local domain resolution
ping vault.local

# Test DNS resolution
nslookup vault.local
```

### Test SSL Tools
```powershell
# Test mkcert
mkcert -version

# Test OpenSSL
openssl version
```

## Alternative: Using Windows Terminal + WSL2

For the best experience, consider using Windows Terminal with WSL2:

1. **Install Windows Terminal**:
   ```powershell
   winget install Microsoft.WindowsTerminal
   ```

2. **Set up Ubuntu in WSL2**:
   ```bash
   # Inside WSL2 Ubuntu
   sudo apt update
   sudo apt install -y docker.io docker-compose-plugin
   ```

3. **Use WSL2 for development**:
   - All Docker commands run in WSL2
   - Better performance and compatibility
   - Native Linux environment

## Next Steps
Once prerequisites are installed:
1. ✅ Docker Desktop running with WSL2
2. ✅ Local domain configured
3. ✅ SSL tools installed
4. ✅ Firewall configured
5. ✅ Network configuration complete

You're ready to proceed with the Vaultwarden setup!