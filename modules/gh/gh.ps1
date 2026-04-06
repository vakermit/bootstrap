Write-Host "== GitHub CLI auth =="

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "gh not found — skipping auth (install it first)"
    return
}

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "gh already authenticated"
} else {
    Write-Host "Authenticating GitHub CLI (opens browser)..."
    gh auth login --web --git-protocol https
}
