#!/usr/bin/env bash

echo "== Common dev tools =="

if command -v brew >/dev/null; then
  brew install git gh
else
  sudo apt install -y git gh || true
fi