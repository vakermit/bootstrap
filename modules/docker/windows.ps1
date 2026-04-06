Write-Host "== Docker via WSL =="

$script = "if ! command -v docker >/dev/null; then curl -fsSL https://get.docker.com | sh; fi"
wsl -e bash -c $script
