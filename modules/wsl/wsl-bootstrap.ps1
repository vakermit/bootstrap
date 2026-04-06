<#
.SYNOPSIS
  Bulletproof WSL installer & preflight for Windows.

.DESCRIPTION
  Installs WSL2 on Windows 10/11 if missing.
  Enables required features (WSL, VirtualMachinePlatform).
  Checks for reboot requirements.
  Installs latest WSL kernel.
  Idempotent: safe to rerun multiple times.

.NOTES
  Tested on Windows 10/11.
#>

# -------------------------------
# Functions
# -------------------------------
function Test-RebootPending {
    $RegPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations"
    )

    foreach ($path in $RegPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    return $false
}

function Enable-WindowsFeatureIfMissing($FeatureName) {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName
    if ($feature.State -ne "Enabled") {
        Write-Host "Enabling Windows feature: $FeatureName..."
        Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart -All
        return $true
    }
    return $false
}

function Install-WSLKernel {
    $wslExe = "$env:SystemRoot\System32\wsl.exe"
    if (-not (Test-Path $wslExe)) {
        Write-Error "wsl.exe not found. Cannot continue."
        exit 1
    }

    Write-Host "Installing/updating WSL kernel..."
    wsl --update
}

function Install-WSL {
    Write-Host "== WSL Bootstrap =="

    # Check reboot pending first
    if (Test-RebootPending) {
        Write-Warning "A reboot is pending. Please restart Windows and rerun this script."
        exit 1
    }

    $needsReboot = $false

    # Enable WSL feature
    if (Enable-WindowsFeatureIfMissing "Microsoft-Windows-Subsystem-Linux") {
        $needsReboot = $true
    }

    # Enable Virtual Machine Platform
    if (Enable-WindowsFeatureIfMissing "VirtualMachinePlatform") {
        $needsReboot = $true
    }

    # Enable Hyper-V if not already (optional, recommended for WSL2)
    if (Enable-WindowsFeatureIfMissing "Microsoft-Hyper-V-All") {
        $needsReboot = $true
    }

    if ($needsReboot) {
        Write-Warning "One or more features were enabled. A reboot is required before continuing."
        exit 1
    }

    # Install/update WSL2 kernel
    Install-WSLKernel

    # Optional: set WSL2 as default version
    wsl --set-default-version 2

    # Optional: list installed distros
    Write-Host "Installed WSL distros:"
    wsl --list --verbose

    Write-Host "WSL Bootstrap complete ✅"
}

# -------------------------------
# Main
# -------------------------------
try {
    Install-WSL
}
catch {
    Write-Error "WSL installation failed: $_"
    exit 1
}