#!/usr/bin/env bash
set -e

echo "== Docker (Colima) =="

if ! command -v colima >/dev/null; then
  brew install colima docker kubectl
fi

# Only start if not already running
if ! colima status >/dev/null 2>&1; then
  colima start --cpu 4 --memory 8 --kubernetes
fi

docker context use colima || true
