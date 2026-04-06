#!/usr/bin/env bash
set -e

echo "== Stage 2 (Private Extensions) =="

REPO="${BOOTSTRAP_STAGE2_REPO:-}"
REF="${BOOTSTRAP_STAGE2_REF:-main}"

if [ -z "$REPO" ]; then
  echo "No BOOTSTRAP_STAGE2_REPO set — skipping Stage 2"
  exit 0
fi

if ! command -v gh >/dev/null || ! gh auth status >/dev/null 2>&1; then
  echo "gh not authenticated — cannot clone private repo. Skipping Stage 2"
  exit 0
fi

TMP_DIR="$(mktemp -d -t bootstrap-stage2-XXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Cloning private repo: $REPO (ref: $REF)..."
gh repo clone "$REPO" "$TMP_DIR/repo" -- --depth 1 --branch "$REF"

if [ -f "$TMP_DIR/repo/install.sh" ]; then
  echo "Running Stage 2 installer..."
  bash "$TMP_DIR/repo/install.sh"
else
  echo "No install.sh found in Stage 2 repo — skipping"
fi

echo "== Stage 2 complete =="
