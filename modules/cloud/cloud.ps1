Write-Host "== Cloud CLIs =="

# Load shared utilities (provides Ensure-ChocoPackage with auto-elevation)
. "$PSScriptRoot\..\..\core\utils.ps1"

# ── AWS CLI ──────────────────────────────────────────────
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Ensure-ChocoPackage "awscli"
} else {
    Write-Host "AWS CLI already installed"
}

# ── Azure CLI ────────────────────────────────────────────
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Ensure-ChocoPackage "azure-cli"
} else {
    Write-Host "Azure CLI already installed"
}

# ── Google Cloud SDK ─────────────────────────────────────
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Ensure-ChocoPackage "gcloudsdk"
} else {
    Write-Host "Google Cloud SDK already installed"
}

# ── Optional interactive auth ────────────────────────────
# Set DO_CLOUD_AUTH=1 to auth all, or DO_CLOUD_AUTH_AWS / _AZURE / _GCP individually

$doAll = $env:DO_CLOUD_AUTH

if ($doAll -or $env:DO_CLOUD_AUTH_AWS) {
    Write-Host "Authenticating AWS CLI..."
    aws configure
}

if ($doAll -or $env:DO_CLOUD_AUTH_AZURE) {
    Write-Host "Authenticating Azure CLI..."
    az login
}

if ($doAll -or $env:DO_CLOUD_AUTH_GCP) {
    Write-Host "Authenticating Google Cloud SDK..."
    gcloud auth login
    gcloud init
}

Write-Host "== Cloud CLIs complete =="
