#!/usr/bin/env bash
set -e

# Ensure we run from the repo root regardless of how we were invoked
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

source core/utils.sh

echo "== Bootstrap Stage 1 starting =="

OS="$(uname)"

# Detect WSL
IS_WSL=false
if [ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=true
  echo "WSL environment detected"
fi

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

# GitHub CLI auth
bash modules/gh/gh.sh

# Python (pyenv + uv)
bash modules/python.sh

# Cloud CLIs (aws, az, gcloud)
bash modules/cloud/cloud.sh

# Docker (late stage)
# In WSL, skip native Docker — Docker Desktop integration is preferred
if [ "$IS_WSL" = true ]; then
  echo "Skipping native Docker install in WSL (use Docker Desktop integration)"
else
  case "$OS" in
    Darwin)
      bash modules/docker/mac.sh
      ;;
    Linux)
      bash modules/docker/linux.sh
      ;;
  esac
fi

bash modules/docker/vscode.sh

# WSL-specific setup (systemd, interop, DNS)
if [ "$IS_WSL" = true ]; then
  bash modules/wsl/linux.sh
fi

# Stage 2 (optional private repo)
bash modules/stage2/stage2.sh

echo "== Bootstrap Stage 1 complete =="
