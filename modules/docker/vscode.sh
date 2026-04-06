#!/usr/bin/env bash

if command -v code >/dev/null; then
  code --install-extension ms-azuretools.vscode-docker || true
  code --install-extension ms-vscode-remote.remote-containers || true
  code --install-extension ms-vscode-remote.remote-wsl || true
fi