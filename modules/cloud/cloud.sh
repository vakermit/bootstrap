#!/usr/bin/env bash
set -e
source core/utils.sh

echo "== Cloud CLIs =="

OS="$(uname)"

# ── AWS CLI ──────────────────────────────────────────────
if ! command_exists aws; then
  echo "Installing AWS CLI..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install awscli
  else
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip -qo /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install --update
    rm -rf /tmp/awscliv2.zip /tmp/aws
  fi
else
  echo "AWS CLI already installed"
fi

# ── Azure CLI ────────────────────────────────────────────
if ! command_exists az; then
  echo "Installing Azure CLI..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install azure-cli
  else
    curl -fsSL https://aka.ms/InstallAzureCLIDeb | sudo bash
  fi
else
  echo "Azure CLI already installed"
fi

# ── Google Cloud SDK ─────────────────────────────────────
if ! command_exists gcloud; then
  echo "Installing Google Cloud SDK..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install --cask google-cloud-sdk
  else
    curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="$HOME"
    export PATH="$HOME/google-cloud-sdk/bin:$PATH"
  fi
else
  echo "Google Cloud SDK already installed"
fi

# ── Optional interactive auth ────────────────────────────
# Set DO_CLOUD_AUTH=1 to auth all, or DO_CLOUD_AUTH_AWS / _AZURE / _GCP individually

do_all="${DO_CLOUD_AUTH:-}"

if [[ -n "$do_all" || -n "${DO_CLOUD_AUTH_AWS:-}" ]]; then
  echo "Authenticating AWS CLI..."
  aws configure
fi

if [[ -n "$do_all" || -n "${DO_CLOUD_AUTH_AZURE:-}" ]]; then
  echo "Authenticating Azure CLI..."
  az login
fi

if [[ -n "$do_all" || -n "${DO_CLOUD_AUTH_GCP:-}" ]]; then
  echo "Authenticating Google Cloud SDK..."
  gcloud auth login
  gcloud init
fi

echo "== Cloud CLIs complete =="
