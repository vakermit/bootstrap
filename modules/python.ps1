Write-Host "== Python (pyenv-win + uv) =="

# Load shared utilities
. "$PSScriptRoot\..\core\utils.ps1"

# pyenv-win
if (-not (Get-Command pyenv -ErrorAction SilentlyContinue)) {
    $pyenvRoot = "$env:USERPROFILE\.pyenv\pyenv-win"

    if (Test-Path "$pyenvRoot\bin\pyenv.bat") {
        Write-Host "pyenv-win found at $pyenvRoot but not on PATH — adding..."
    }
    else {
        Write-Host "Installing pyenv-win via git clone..."
        $pyenvParent = "$env:USERPROFILE\.pyenv"
        if (Test-Path $pyenvParent) {
            Remove-Item -Recurse -Force $pyenvParent
        }
        git clone https://github.com/pyenv-win/pyenv-win.git $pyenvParent
    }

    # Add to current session PATH
    $env:PYENV = $pyenvRoot
    $env:PYENV_HOME = $pyenvRoot
    $env:PATH = "$pyenvRoot\bin;$pyenvRoot\shims;$env:PATH"

    # Persist to user PATH for future sessions
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $toAdd = @("$pyenvRoot\bin", "$pyenvRoot\shims")
    foreach ($p in $toAdd) {
        if ($userPath -notlike "*$p*") {
            $userPath = "$p;$userPath"
        }
    }
    [Environment]::SetEnvironmentVariable('Path', $userPath, 'User')
    [Environment]::SetEnvironmentVariable('PYENV', $pyenvRoot, 'User')
    [Environment]::SetEnvironmentVariable('PYENV_HOME', $pyenvRoot, 'User')
}
else {
    Write-Host "pyenv already installed"
}

pyenv install 3.11.9 --skip-existing
pyenv install 3.14-dev --skip-existing
pyenv global 3.11.9

# uv
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing uv..."
    irm https://astral.sh/uv/install.ps1 | iex
} else {
    Write-Host "uv already installed"
}

Write-Host "== Python setup complete =="
