#!/usr/bin/env bash
# Smoke test — runs the bootstrap in a disposable Docker container
# and checks that expected binaries are present afterward.
#
# Usage: bash test/smoke.linux.sh
#
# Requires: docker

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="ubuntu:24.04"

echo "== Bootstrap Linux smoke test =="
echo "Image:  $IMAGE"
echo "Repo:   $SCRIPT_DIR"
echo ""

docker run --rm \
  -v "$SCRIPT_DIR":/bootstrap:ro \
  "$IMAGE" \
  bash -c '
    set -e

    apt-get update -qq
    apt-get install -y -qq curl git sudo unzip >/dev/null 2>&1

    # Copy repo to writable location (bind mount is read-only)
    cp -r /bootstrap /tmp/bootstrap
    cd /tmp/bootstrap

    bash install.local.sh

    echo ""
    echo "── Smoke check ──"
    PASS=0
    FAIL=0
    for cmd in git gh pyenv uv aws az gcloud docker code; do
      if command -v "$cmd" >/dev/null 2>&1; then
        echo "  OK:      $cmd"
        PASS=$((PASS + 1))
      else
        echo "  MISSING: $cmd"
        FAIL=$((FAIL + 1))
      fi
    done

    echo ""
    echo "Results: $PASS passed, $FAIL missing"

    if [ "$FAIL" -gt 0 ]; then
      echo "Some tools were not installed (may be expected in container)"
      exit 1
    fi
  '

echo ""
echo "== Smoke test complete =="
