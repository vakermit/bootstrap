Write-Host "== Windows setup =="

function Ensure-Choco {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
}

function Ensure-Package {
    param ($pkg)
    if (-not (choco list --local-only | Select-String $pkg)) {
        choco install $pkg -y
    }
}

Ensure-Choco

Get-Content "packages/choco.txt" | ForEach-Object {
    Ensure-Package $_
}

# WSL
if (-not (wsl --status 2>$null)) {
    wsl --install -d Ubuntu
}

# Run Linux bootstrap inside WSL (clone + run local installer so WSL detection works)
$repoUrl = "https://github.com/vakermit/bootstrap.git"
wsl -e bash -c "git clone --depth 1 $repoUrl /tmp/bootstrap-wsl 2>/dev/null || git -C /tmp/bootstrap-wsl pull; cd /tmp/bootstrap-wsl && bash install.local.sh"
