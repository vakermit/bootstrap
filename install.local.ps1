Write-Host "== Master Installer starting (Windows) =="


# -------------------------------
# WSL Preflight / Bootstrap Check
# -------------------------------

# Path to your WSL bootstrap script
$wslBootstrap = ".\modules\wsl\wsl-bootstrap.ps1"

function Test-WSLInstalled {
    try {
        $output = wsl.exe --list --quiet 2>$null
        return $output -ne $null
    }
    catch {
        return $false
    }
}

# Only run if WSL is missing
if (-not (Test-WSLInstalled)) {

    Write-Host "WSL is not installed. Preparing to bootstrap WSL..."

    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")

    if (-not $isAdmin) {
        Write-Warning "Administrator privileges are required to install WSL."
        Write-Host "Launching elevated PowerShell to run WSL bootstrap..."
        
        # Launch new elevated PowerShell to run WSL bootstrap only, no loops
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$wslBootstrap`""
        
        Write-Host "Please wait for WSL bootstrap to complete, then re-run this installer."
        exit 0
    }

    # Already admin, run bootstrap directly
    Write-Host "Running WSL bootstrap..."
    & $wslBootstrap

    # WSL should now be installed
    if (-not (Test-WSLInstalled)) {
        Write-Error "WSL bootstrap did not complete successfully. Exiting."
        exit 1
    }

    Write-Host "WSL installation complete. Continuing with main installer..."
}
else {
    Write-Host "WSL already installed. Skipping WSL bootstrap."
}

# Base Windows setup
.\modules\windows.ps1

# Python
.\modules\python.ps1

# Docker
.\modules\docker\windows.ps1

Write-Host "== Master Installer complete =="