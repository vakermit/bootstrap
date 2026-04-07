Write-Host "== Windows setup =="

# Load shared utilities (provides Ensure-ChocoPackage with auto-elevation)
. "$PSScriptRoot\..\core\utils.ps1"

# Install choco packages from list
$chocoList = Join-Path $PSScriptRoot "..\packages\choco.txt"
if (Test-Path $chocoList) {
    Get-Content $chocoList | Where-Object { $_ -match '\S' } | ForEach-Object {
        Ensure-ChocoPackage $_
    }
}
else {
    Write-Host "  ! " -ForegroundColor Yellow -NoNewline
    Write-Host "packages/choco.txt not found — skipping choco packages"
}

# WSL
if (-not (wsl --status 2>$null)) {
    wsl --install -d Ubuntu
}

# Run Linux bootstrap inside WSL (clone + run local installer so WSL detection works)
$repoUrl = "https://github.com/vakermit/bootstrap.git"
wsl -e bash -c "git clone --depth 1 $repoUrl /tmp/bootstrap-wsl 2>/dev/null || git -C /tmp/bootstrap-wsl pull; cd /tmp/bootstrap-wsl && bash install.local.sh"
