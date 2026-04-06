#!/usr/bin/env bash
set -e
source core/utils.sh

echo "== GitHub CLI auth =="

if ! command_exists gh; then
  echo "gh not found — skipping auth (install it first)"
  exit 0
fi

if gh auth status >/dev/null 2>&1; then
  echo "gh already authenticated"
else
  echo "Authenticating GitHub CLI (opens browser)..."
  gh auth login --web --git-protocol https
fi
