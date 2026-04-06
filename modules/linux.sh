#!/usr/bin/env bash
set -e
source core/utils.sh

echo "== Linux setup =="

sudo apt update

while read -r pkg; do
  ensure_apt_package "$pkg"
done < packages/apt.txt

# VS Code
if ! command_exists code; then
  sudo snap install code --classic || true
fi