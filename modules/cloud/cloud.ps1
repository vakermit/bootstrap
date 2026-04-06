Write-Host "== Cloud CLIs =="

# ── AWS CLI ──────────────────────────────────────────────
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "Installing AWS CLI..."
    choco install awscli -y
} else {
    Write-Host "AWS CLI already installed"
}

# ── Azure CLI ────────────────────────────────────────────
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Azure CLI..."
    choco install azure-cli -y
} else {
    Write-Host "Azure CLI already installed"
}

# ── Google Cloud SDK ─────────────────────────────────────
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Google Cloud SDK..."
    choco install gcloudsdk -y
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
