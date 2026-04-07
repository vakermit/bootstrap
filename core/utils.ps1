# core/utils.ps1 — Shared PowerShell utilities for bootstrap

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-Elevated {
    <#
    .SYNOPSIS
      Run a PowerShell script block in a separate elevated (admin) window.
      Returns $true if the elevated process exited 0.
    #>
    param(
        [Parameter(Mandatory)][string]$Description,
        [Parameter(Mandatory)][string]$ScriptContent
    )

    if (Test-IsAdmin) {
        # Already admin — run inline
        $tmpScript = Join-Path $env:TEMP "bootstrap-inline-$(Get-Random).ps1"
        Set-Content -Path $tmpScript -Value $ScriptContent -Encoding UTF8
        try {
            $proc = Start-Process powershell.exe -ArgumentList @(
                '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $tmpScript
            ) -Wait -PassThru -NoNewWindow
            return ($proc.ExitCode -eq 0)
        }
        finally {
            Remove-Item -Path $tmpScript -ErrorAction SilentlyContinue
        }
    }

    Write-Host "  ! " -ForegroundColor Yellow -NoNewline
    Write-Host "Admin required: $Description — launching elevated window..."

    $tmpScript = Join-Path $env:TEMP "bootstrap-elevated-$(Get-Random).ps1"
    Set-Content -Path $tmpScript -Value $ScriptContent -Encoding UTF8

    try {
        $proc = Start-Process powershell.exe -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $tmpScript
        ) -Verb RunAs -Wait -PassThru

        return ($proc.ExitCode -eq 0)
    }
    catch {
        Write-Host "  x " -ForegroundColor Red -NoNewline
        Write-Host "Elevation cancelled or failed for: $Description"
        return $false
    }
    finally {
        Remove-Item -Path $tmpScript -ErrorAction SilentlyContinue
    }
}

function Refresh-PathFromRegistry {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

function Ensure-Choco {
    if (Get-Command choco -ErrorAction SilentlyContinue) { return $true }

    Write-Host "Installing Chocolatey package manager..."
    $script = @'
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
exit $LASTEXITCODE
'@
    $ok = Invoke-Elevated -Description "Install Chocolatey" -ScriptContent $script
    Refresh-PathFromRegistry
    return $ok
}

function Ensure-ChocoPackage {
    <#
    .SYNOPSIS
      Install a Chocolatey package, elevating to admin if needed.
    #>
    param([Parameter(Mandatory)][string]$Package)

    if (-not (Ensure-Choco)) {
        Write-Host "  x " -ForegroundColor Red -NoNewline
        Write-Host "Chocolatey not available — cannot install $Package"
        return $false
    }

    # Check if already installed
    $installed = choco list --local-only 2>$null | Select-String "^$Package\s"
    if ($installed) {
        Write-Host "  + " -ForegroundColor Green -NoNewline
        Write-Host "$Package already installed"
        return $true
    }

    Write-Host "Installing $Package via Chocolatey..."
    $script = @"
choco install $Package -y --no-progress
exit `$LASTEXITCODE
"@
    $ok = Invoke-Elevated -Description "Install $Package" -ScriptContent $script
    Refresh-PathFromRegistry

    if ($ok) {
        Write-Host "  + " -ForegroundColor Green -NoNewline
        Write-Host "$Package installed"
    }
    else {
        Write-Host "  x " -ForegroundColor Red -NoNewline
        Write-Host "Failed to install $Package"
    }
    return $ok
}
