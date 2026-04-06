#!/usr/bin/env bash
set -e
source core/utils.sh

echo "== Python (pyenv + uv) =="

# pyenv
if ! command -v pyenv >/dev/null; then
  curl https://pyenv.run | bash
fi

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

pyenv install -s 3.11.9
pyenv install -s 3.14-dev
pyenv global 3.11.9

# uv
if ! command -v uv >/dev/null; then
  curl -Ls https://astral.sh/uv/install.sh | bash
fi

export PATH="$HOME/.local/bin:$PATH"