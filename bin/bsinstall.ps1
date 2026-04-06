param(
    [Parameter(Mandatory=$true)]
    [string]$Repo,

    [string]$Ref
)

Write-Host "== bsinstall (Stage 2) =="
Write-Host "Repo: $Repo"
if ($Ref) { Write-Host "Ref: $Ref" }

# -------------------------------
# Check gh installed
# -------------------------------
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "gh CLI is not installed"
    exit 1
}

# -------------------------------
# Check gh auth
# -------------------------------
try {
    gh auth status | Out-Null
} catch {
    Write-Host "gh not authenticated. Launching login..."
    gh auth login --web --git-protocol https
}

try {
    gh auth status | Out-Null
} catch {
    Write-Error "gh authentication failed"
    exit 1
}

# -------------------------------
# Fetch bootstrap.yml
# -------------------------------
$apiPath = "repos/$Repo/contents/bootstrap.yml"
if ($Ref) { $apiPath += "?ref=$Ref" }

try {
    $content = gh api $apiPath --jq .content
    $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($content))
} catch {
    Write-Error "Failed to fetch bootstrap.yml"
    exit 1
}

# -------------------------------
# Extract install_dir
# -------------------------------
$installDir = $null

if (Get-Command yq -ErrorAction SilentlyContinue) {
    $installDir = $decoded | yq -r ".install_dir"
} else {
    $line = $decoded | Select-String "install_dir"
    if ($line) {
        $installDir = ($line -split ":")[1].Trim()
    }
}

if (-not $installDir -or $installDir -eq "null") {
    Write-Error "install_dir not defined in bootstrap.yml"
    exit 1
}

# Expand ~
if ($installDir.StartsWith("~")) {
    $installDir = $installDir.Replace("~", $HOME)
}

Write-Host "Install dir: $installDir"

# -------------------------------
# Clone or update
# -------------------------------
if (Test-Path "$installDir\.git") {
    Write-Host "Updating existing repo..."
    git -C $installDir pull
} else {
    Write-Host "Cloning repo..."
    gh repo clone $Repo $installDir
}

Set-Location $installDir

# -------------------------------
# Run installer
# -------------------------------
if (Test-Path "install.ps1") {
    Write-Host "Running install.ps1..."
    powershell -ExecutionPolicy Bypass -File .\install.ps1
}
elseif (Test-Path "install.sh") {
    Write-Host "Running install.sh via WSL..."
    wsl bash install.sh
}
else {
    Write-Error "No install script found"
    exit 1
}

Write-Host "Stage 2 complete ✅"