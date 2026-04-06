$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/vakermit/bootstrap.git"
$BRANCH = "main"
$TMP_DIR = Join-Path $env:TEMP ("bootstrap-" + [guid]::NewGuid())
$LOG_FILE = "$env:USERPROFILE\bootstrap.log"

Write-Host "== Bootstrap Stage 0 =="

New-Item -ItemType Directory -Path $TMP_DIR | Out-Null

Start-Transcript -Path $LOG_FILE -Append

# ------------------------
# Ensure git
# ------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing git..."

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }

    choco install git -y
}

# ------------------------
# Clone repo
# ------------------------
git clone --depth 1 --branch $BRANCH $REPO_URL "$TMP_DIR\repo"

Set-Location "$TMP_DIR\repo"

# ------------------------
# Run Stage 1
# ------------------------
.\install.local.ps1

Stop-Transcript

if ($env:BOOTSTRAP_CLEANUP) {
    Write-Host "BOOTSTRAP_CLEANUP set — removing $TMP_DIR"
    Remove-Item -Recurse -Force $TMP_DIR -ErrorAction SilentlyContinue
} else {
    Write-Host "Temp repo kept at: $TMP_DIR\repo"
    Write-Host "Set BOOTSTRAP_CLEANUP=1 to auto-remove on next run."
}

Write-Host "== Bootstrap complete =="