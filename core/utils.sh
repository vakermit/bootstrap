command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_brew_package() {
  if ! brew list "$1" >/dev/null 2>&1; then
    brew install "$1"
  else
    echo "$1 already installed"
  fi
}

ensure_apt_package() {
  if ! dpkg -s "$1" >/dev/null 2>&1; then
    sudo apt install -y "$1"
  else
    echo "$1 already installed"
  fi
}

append_if_missing() {
  grep -qxF "$1" "$2" 2>/dev/null || echo "$1" >> "$2"
}