Write-Host "== Bootstrap Stage 1 starting (Windows) =="

# Load shared utilities (Test-IsAdmin, Invoke-Elevated, Ensure-ChocoPackage, etc.)
. "$PSScriptRoot\core\utils.ps1"

# Show admin status
if (Test-IsAdmin) {
    Write-Host "  + " -ForegroundColor Green -NoNewline
    Write-Host "Running as Administrator — all installs will run inline"
}
else {
    Write-Host "  i " -ForegroundColor Blue -NoNewline
    Write-Host "Running as standard user — admin tools (Chocolatey, etc.) will prompt for elevation"
}

# -------------------------------
# WSL Preflight / Bootstrap Check
# -------------------------------

$wslBootstrap = Join-Path $PSScriptRoot "modules\wsl\wsl-bootstrap.ps1"

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

    $wslScript = Get-Content $wslBootstrap -Raw
    $ok = Invoke-Elevated -Description "Install WSL" -ScriptContent $wslScript

    if (-not $ok) {
        Write-Host "  x " -ForegroundColor Red -NoNewline
        Write-Host "WSL bootstrap failed. You may need to reboot and re-run."
        exit 1
    }

    if (-not (Test-WSLInstalled)) {
        Write-Host "  ! " -ForegroundColor Yellow -NoNewline
        Write-Host "WSL may require a reboot. Please restart and re-run this installer."
        exit 1
    }

    Write-Host "WSL installation complete. Continuing with main installer..."
}
else {
    Write-Host "WSL already installed. Skipping WSL bootstrap."
}

# Base Windows setup (Chocolatey packages — auto-elevates per package)
. "$PSScriptRoot\modules\windows.ps1"

# GitHub CLI auth
. "$PSScriptRoot\modules\gh\gh.ps1"

# Python
. "$PSScriptRoot\modules\python.ps1"

# Cloud CLIs (aws, az, gcloud — auto-elevates for choco installs)
. "$PSScriptRoot\modules\cloud\cloud.ps1"

# Docker
. "$PSScriptRoot\modules\docker\windows.ps1"

# Stage 2 (optional private repo)
. "$PSScriptRoot\modules\stage2\stage2.ps1"

Write-Host "== Bootstrap Stage 1 complete =="
