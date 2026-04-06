Write-Host "== Docker via WSL =="

wsl -e bash -c @"
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sh
fi
"@