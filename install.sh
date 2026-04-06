#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/vakermit/bootstrap.git"
BRANCH="main"

LOG_FILE="${HOME}/bootstrap.log"
TMP_DIR="$(mktemp -d -t bootstrap-XXXX)"

trap 'rm -rf "$TMP_DIR"' EXIT

echo "== Bootstrap Stage 0 ==" | tee -a "$LOG_FILE"
echo "Temp dir: $TMP_DIR" | tee -a "$LOG_FILE"

# ------------------------
# Logging everything
# ------------------------
exec > >(tee -a "$LOG_FILE") 2>&1

# ------------------------
# Ensure git exists
# ------------------------
install_git() {
  echo "Installing git..."

  if [[ "$OSTYPE" == "darwin"* ]]; then
    xcode-select --install || true
  elif command -v apt >/dev/null; then
    sudo apt update
    sudo apt install -y git
  elif command -v yum >/dev/null; then
    sudo yum install -y git
  else
    echo "Unsupported OS for auto git install"
    exit 1
  fi
}

if ! command -v git >/dev/null; then
  install_git
else
  echo "git already installed"
fi

# ------------------------
# Clone repo
# ------------------------
echo "Cloning bootstrap repo..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR/repo"

cd "$TMP_DIR/repo"

# ------------------------
# Run Stage 1 (real install)
# ------------------------
bash ./install.local.sh

echo "== Bootstrap complete =="