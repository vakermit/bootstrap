#!/usr/bin/env bash
set -e

echo "== Master Linux starting =="

OS="$(uname)"

# Core modules
case "$OS" in
  Darwin)
    bash modules/mac.sh
    ;;
  Linux)
    bash modules/linux.sh
    ;;
  *)
    echo "Unsupported OS"
    exit 1
    ;;
esac

# Shared dev tools
bash modules/common_dev.sh

# Python (pyenv + uv)
bash modules/python.sh

# Docker (late stage)
case "$OS" in
  Darwin)
    bash modules/docker/mac.sh
    ;;
  Linux)
    bash modules/docker/linux.sh
    ;;
esac

bash modules/docker/vscode.sh

echo "== Bootstrap complete =="