#!/usr/bin/env bash
set -e
source core/utils.sh

echo "== Common dev tools =="

# git and gh are already installed by mac.sh/linux.sh via package lists.
# This module handles any shared dev config that isn't package-specific.

# Verify critical tools are present
for tool in git gh; do
  if ! command_exists "$tool"; then
    echo "WARNING: $tool not found after platform setup"
  fi
done
