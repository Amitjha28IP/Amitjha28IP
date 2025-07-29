# Vaultwarden Windows Deployment Script
# This script sets up and deploys Vaultwarden locally on Windows

param(
    [switch]$Setup,
    [switch]$Start,
    [switch]$Stop,
    [switch]$Restart,
    [switch]$Logs,
    [switch]$Clean,
    [switch]$Help
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Cyan"

function Show-Help {
    Write-Host "Vaultwarden Windows Deployment Script" -ForegroundColor $Green
    Write-Host "=====================================" -ForegroundColor $Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor $Yellow
    Write-Host "  .\deploy-windows.ps1 -Setup     # Initial setup (SSL, hosts, environment)"
    Write-Host "  .\deploy-windows.ps1 -Start     # Start Vaultwarden services"
    Write-Host "  .\deploy-windows.ps1 -Stop      # Stop Vaultwarden services"
    Write-Host "  .\deploy-windows.ps1 -Restart   # Restart Vaultwarden services"
    Write-Host "  .\deploy-windows.ps1 -Logs      # Show service logs"
    Write-Host "  .\deploy-windows.ps1 -Clean     # Clean up containers and volumes"
    Write-Host "  .\deploy-windows.ps1 -Help      # Show this help"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Yellow
    Write-Host "  # First time setup"
    Write-Host "  .\deploy-windows.ps1 -Setup"
    Write-Host ""
    Write-Host "  # Start services"
    Write-Host "  .\deploy-windows.ps1 -Start"
    Write-Host ""
    Write-Host "  # View logs"
    Write-Host "  .\deploy-windows.ps1 -Logs"
}

function Test-Prerequisites {
    Write-Host "🔍 Checking prerequisites..." -ForegroundColor $Blue
    
    # Check Docker
    try {
        docker --version | Out-Null
        Write-Host "✅ Docker is available" -ForegroundColor $Green
    } catch {
        Write-Host "❌ Docker is not available" -ForegroundColor $Red
        Write-Host "   Please install Docker Desktop for Windows" -ForegroundColor $Yellow
        return $false
    }
    
    # Check Docker Compose
    try {
        docker compose version | Out-Null
        Write-Host "✅ Docker Compose is available" -ForegroundColor $Green
    } catch {
        Write-Host "❌ Docker Compose is not available" -ForegroundColor $Red
        return $false
    }
    
    # Check if Docker is running
    try {
        docker ps | Out-Null
        Write-Host "✅ Docker daemon is running" -ForegroundColor $Green
    } catch {
        Write-Host "❌ Docker daemon is not running" -ForegroundColor $Red
        Write-Host "   Please start Docker Desktop" -ForegroundColor $Yellow
        return $false
    }
    
    return $true
}

function Setup-Environment {
    Write-Host "🚀 Setting up Vaultwarden environment..." -ForegroundColor $Green
    
    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Host "❌ Prerequisites not met. Please install required software." -ForegroundColor $Red
        return
    }
    
    # Setup hosts file
    Write-Host "📝 Configuring hosts file..." -ForegroundColor $Blue
    $hostsFile = "C:\Windows\System32\drivers\etc\hosts"
    $domain = "127.0.0.1    vault.local"
    
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if ($isAdmin) {
        $exists = Get-Content $hostsFile | Select-String "vault.local"
        if (-not $exists) {
            Add-Content -Path $hostsFile -Value $domain
            Write-Host "✅ Added vault.local to hosts file" -ForegroundColor $Green
        } else {
            Write-Host "✅ vault.local already exists in hosts file" -ForegroundColor $Green
        }
        
        # Flush DNS
        ipconfig /flushdns | Out-Null
        Write-Host "✅ DNS cache flushed" -ForegroundColor $Green
    } else {
        Write-Host "⚠️  Warning: Not running as Administrator" -ForegroundColor $Yellow
        Write-Host "   Please add '127.0.0.1    vault.local' to C:\Windows\System32\drivers\etc\hosts manually" -ForegroundColor $Yellow
    }
    
    # Setup SSL certificates
    Write-Host "🔐 Setting up SSL certificates..." -ForegroundColor $Blue
    if (Test-Path ".\windows-ssl-setup.ps1") {
        & .\windows-ssl-setup.ps1
    } else {
        Write-Host "⚠️  SSL setup script not found" -ForegroundColor $Yellow
        Write-Host "   Please run windows-ssl-setup.ps1 manually" -ForegroundColor $Yellow
    }
    
    # Setup environment file
    Write-Host "⚙️  Setting up environment file..." -ForegroundColor $Blue
    if (-not (Test-Path ".env")) {
        if (Test-Path ".env.local") {
            Copy-Item ".env.local" ".env"
            Write-Host "✅ Created .env from template" -ForegroundColor $Green
            Write-Host "⚠️  Please edit .env file with your actual values:" -ForegroundColor $Yellow
            Write-Host "   - ADMIN_TOKEN (generate with OpenSSL or PowerShell)" -ForegroundColor $Yellow
            Write-Host "   - GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET" -ForegroundColor $Yellow
        } else {
            Write-Host "❌ .env.local template not found" -ForegroundColor $Red
        }
    } else {
        Write-Host "✅ .env file already exists" -ForegroundColor $Green
    }
    
    Write-Host ""
    Write-Host "✅ Setup completed!" -ForegroundColor $Green
    Write-Host "Next steps:" -ForegroundColor $Yellow
    Write-Host "  1. Edit .env file with your configuration"
    Write-Host "  2. Set up Google OAuth (see google-oauth-local-setup.md)"
    Write-Host "  3. Run: .\deploy-windows.ps1 -Start"
}

function Start-Services {
    Write-Host "🚀 Starting Vaultwarden services..." -ForegroundColor $Green
    
    if (-not (Test-Prerequisites)) {
        return
    }
    
    if (-not (Test-Path ".env")) {
        Write-Host "❌ .env file not found" -ForegroundColor $Red
        Write-Host "   Run: .\deploy-windows.ps1 -Setup" -ForegroundColor $Yellow
        return
    }
    
    if (-not (Test-Path "ssl\cert.pem")) {
        Write-Host "❌ SSL certificates not found" -ForegroundColor $Red
        Write-Host "   Run: .\deploy-windows.ps1 -Setup" -ForegroundColor $Yellow
        return
    }
    
    try {
        docker compose -f docker-compose.local.yml up -d
        Write-Host "✅ Services started successfully!" -ForegroundColor $Green
        Write-Host ""
        Write-Host "🌐 Access Vaultwarden at: https://vault.local" -ForegroundColor $Green
        Write-Host "🔧 Admin panel at: https://vault.local/admin" -ForegroundColor $Green
        Write-Host ""
        Write-Host "📋 Service status:" -ForegroundColor $Yellow
        docker compose -f docker-compose.local.yml ps
    } catch {
        Write-Host "❌ Failed to start services" -ForegroundColor $Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor $Red
    }
}

function Stop-Services {
    Write-Host "⏹️  Stopping Vaultwarden services..." -ForegroundColor $Yellow
    
    try {
        docker compose -f docker-compose.local.yml down
        Write-Host "✅ Services stopped successfully!" -ForegroundColor $Green
    } catch {
        Write-Host "❌ Failed to stop services" -ForegroundColor $Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor $Red
    }
}

function Restart-Services {
    Write-Host "🔄 Restarting Vaultwarden services..." -ForegroundColor $Blue
    Stop-Services
    Start-Sleep -Seconds 2
    Start-Services
}

function Show-Logs {
    Write-Host "📋 Showing Vaultwarden logs..." -ForegroundColor $Blue
    Write-Host "Press Ctrl+C to exit logs" -ForegroundColor $Yellow
    Write-Host ""
    
    try {
        docker compose -f docker-compose.local.yml logs -f
    } catch {
        Write-Host "❌ Failed to show logs" -ForegroundColor $Red
    }
}

function Clean-Environment {
    Write-Host "🧹 Cleaning up Vaultwarden environment..." -ForegroundColor $Yellow
    
    $confirm = Read-Host "This will remove all containers, volumes, and data. Continue? (y/N)"
    if ($confirm -eq "y" -or $confirm -eq "Y") {
        try {
            docker compose -f docker-compose.local.yml down -v --remove-orphans
            docker system prune -f
            Write-Host "✅ Environment cleaned successfully!" -ForegroundColor $Green
        } catch {
            Write-Host "❌ Failed to clean environment" -ForegroundColor $Red
        }
    } else {
        Write-Host "❌ Cleanup cancelled" -ForegroundColor $Yellow
    }
}

# Main script logic
if ($Help) {
    Show-Help
} elseif ($Setup) {
    Setup-Environment
} elseif ($Start) {
    Start-Services
} elseif ($Stop) {
    Stop-Services
} elseif ($Restart) {
    Restart-Services
} elseif ($Logs) {
    Show-Logs
} elseif ($Clean) {
    Clean-Environment
} else {
    Write-Host "❌ No action specified" -ForegroundColor $Red
    Write-Host ""
    Show-Help
}