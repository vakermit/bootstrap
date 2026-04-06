#!/usr/bin/env bash
set -e

echo "== Docker (Colima) =="

if ! command -v colima >/dev/null; then
  brew install colima docker kubectl
fi

colima start --cpu 4 --memory 8 --kubernetes || true
docker context use colima || true