#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${HOME}/bootstrap.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# -------------------------------
# Args
# -------------------------------
if [ $# -lt 1 ]; then
    echo "Usage: bsinstall.sh <owner/repo> [ref]"
    exit 1
fi

REPO="$1"
REF="${2:-main}"

echo "== bsinstall (Stage 2) =="
echo "Repo: $REPO"
echo "Ref:  $REF"

# -------------------------------
# Check gh installed
# -------------------------------
if ! command -v gh >/dev/null 2>&1; then
    echo "Error: gh CLI is not installed"
    exit 1
fi

# -------------------------------
# Check gh auth
# -------------------------------
if ! gh auth status >/dev/null 2>&1; then
    echo "gh is not authenticated. Launching login..."
    gh auth login --web --git-protocol https
fi

# Verify again (fail if still not authed)
if ! gh auth status >/dev/null 2>&1; then
    echo "Error: gh authentication failed"
    exit 1
fi

# -------------------------------
# Portable base64 decode
# -------------------------------
b64decode() {
    if base64 --decode </dev/null 2>/dev/null; then
        base64 --decode
    elif base64 -D </dev/null 2>/dev/null; then
        base64 -D
    else
        base64 -d
    fi
}

# -------------------------------
# Fetch bootstrap.yml
# -------------------------------
echo "Fetching bootstrap.yml..."

API_PATH="repos/$REPO/contents/bootstrap.yml?ref=$REF"

RAW_CONTENT=$(gh api "$API_PATH" --jq .content 2>/dev/null) || {
    echo "Error: Failed to fetch bootstrap.yml from $REPO (ref: $REF)"
    exit 1
}

CONFIG_CONTENT=$(echo "$RAW_CONTENT" | b64decode) || {
    echo "Error: Failed to decode bootstrap.yml content"
    exit 1
}

# -------------------------------
# Extract install_dir
# -------------------------------
if command -v yq >/dev/null 2>&1; then
    INSTALL_DIR=$(echo "$CONFIG_CONTENT" | yq -r '.install_dir')
else
    # Portable fallback: strip key, quotes, inline comments, and trim whitespace
    INSTALL_DIR=$(echo "$CONFIG_CONTENT" | grep '^install_dir:' | sed 's/^install_dir:[[:space:]]*//' | sed 's/#.*//' | sed 's/^["'\'']//' | sed 's/["'\''][[:space:]]*$//' | tr -d '[:space:]')
fi

if [ -z "$INSTALL_DIR" ] || [ "$INSTALL_DIR" = "null" ]; then
    echo "Error: install_dir not defined in bootstrap.yml"
    exit 1
fi

# Expand ~ safely
INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"

echo "Install dir: $INSTALL_DIR"

# -------------------------------
# Clone or update
# -------------------------------
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Updating existing repo..."
    git -C "$INSTALL_DIR" fetch origin
    git -C "$INSTALL_DIR" checkout "$REF" 2>/dev/null || git -C "$INSTALL_DIR" checkout "origin/$REF"
    git -C "$INSTALL_DIR" pull origin "$REF" || true
else
    # Clean up any partial clone from a previous failed attempt
    if [ -d "$INSTALL_DIR" ] && [ -n "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]; then
        echo "Warning: $INSTALL_DIR exists but is not a git repo. Backing up..."
        mv "$INSTALL_DIR" "${INSTALL_DIR}.bak.$(date +%s)"
    fi

    echo "Cloning repo..."
    gh repo clone "$REPO" "$INSTALL_DIR" -- --branch "$REF"
fi

# -------------------------------
# Run installer
# -------------------------------
cd "$INSTALL_DIR"

if [ -f install.sh ]; then
    echo "Running install.sh..."
    bash install.sh
elif [ -f install.ps1 ]; then
    echo "Running install.ps1..."
    pwsh install.ps1
else
    echo "Error: No install script found in repo"
    exit 1
fi

echo "== bsinstall complete =="
