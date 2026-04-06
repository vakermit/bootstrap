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

# Packages from brew.txt
while read -r pkg; do
  [[ -z "$pkg" || "$pkg" == \#* ]] && continue
  ensure_brew_package "$pkg"
done < packages/brew.txt

# Cask apps (idempotent)
for cask in iterm2 visual-studio-code; do
  if ! brew list --cask "$cask" >/dev/null 2>&1; then
    brew install --cask "$cask"
  else
    echo "$cask already installed"
  fi
done
