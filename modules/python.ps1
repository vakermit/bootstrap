Write-Host "== Python (pyenv-win + uv) =="

# pyenv-win
if (-not (Get-Command pyenv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing pyenv-win..."
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "$env:TEMP\install-pyenv-win.ps1"
    & "$env:TEMP\install-pyenv-win.ps1"

    # Add to current session PATH
    $env:PATH = "$env:USERPROFILE\.pyenv\pyenv-win\bin;$env:USERPROFILE\.pyenv\pyenv-win\shims;$env:PATH"
} else {
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
