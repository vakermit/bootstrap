#!/usr/bin/env bash
set -e

echo "== Docker (Linux) =="

if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
fi
