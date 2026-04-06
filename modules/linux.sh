#!/usr/bin/env bash
set -e
source core/utils.sh

echo "== Linux setup =="

sudo apt update

while read -r pkg; do
  ensure_apt_package "$pkg"
done < packages/apt.txt

# VS Code — skip on WSL (Windows VS Code + Remote-WSL extension is preferred)
if [ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null; then
  echo "WSL detected — skipping VS Code snap install (use Windows VS Code + Remote-WSL)"
elif ! command_exists code; then
  sudo snap install code --classic || true
fi
