Write-Host "== Stage 2 (Private Extensions) =="

$Repo = $env:BOOTSTRAP_STAGE2_REPO
$Ref = if ($env:BOOTSTRAP_STAGE2_REF) { $env:BOOTSTRAP_STAGE2_REF } else { "main" }

if (-not $Repo) {
    Write-Host "No BOOTSTRAP_STAGE2_REPO set — skipping Stage 2"
    return
}

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "gh not authenticated — cannot clone private repo. Skipping Stage 2"
    return
}

$TmpDir = Join-Path $env:TEMP ("bootstrap-stage2-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $TmpDir | Out-Null

try {
    Write-Host "Cloning private repo: $Repo (ref: $Ref)..."
    gh repo clone $Repo "$TmpDir\repo" -- --depth 1 --branch $Ref

    $installer = Join-Path "$TmpDir\repo" "install.ps1"
    if (Test-Path $installer) {
        Write-Host "Running Stage 2 installer..."
        & $installer
    } else {
        Write-Host "No install.ps1 found in Stage 2 repo — skipping"
    }
} finally {
    Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
}

Write-Host "== Stage 2 complete =="
