#!/usr/bin/env bash
set -e
source core/utils.sh

echo "== macOS setup =="

# Xcode CLI tools
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
fi

# Homebrew
if ! command_exists brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Packages
while read -r pkg; do
  ensure_brew_package "$pkg"
done < packages/brew.txt

# Terminal + VS Code
brew install --cask iterm2
brew install --cask visual-studio-code