#!/usr/bin/env bash
set -e
source core/utils.sh

echo "== Docker (Linux) =="

if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
fi
