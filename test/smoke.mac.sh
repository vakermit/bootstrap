#!/usr/bin/env bash
# Smoke test — creates a temporary macOS user, prints credentials,
# and prepares a one-liner the test user can run after login.
#
# Usage: sudo bash test/smoke.mac.sh
#
# After the script finishes, switch to the test user (Fast User Switching
# or log out) and run the command it prints.
#
# Cleanup: sudo bash test/smoke.mac.sh --cleanup

set -euo pipefail

TEST_USER="bootstraptest"
TEST_UID="599"
REPO_URL="https://github.com/vakermit/bootstrap.git"

# ── Cleanup mode ─────────────────────────────────────────
if [[ "${1:-}" == "--cleanup" ]]; then
  echo "Removing test user: $TEST_USER"
  sudo dscl . -delete "/Users/$TEST_USER" 2>/dev/null || true
  sudo rm -rf "/Users/$TEST_USER"
  echo "Done."
  exit 0
fi

# ── Must run as root ─────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo bash $0"
  exit 1
fi

# ── Check if user already exists ─────────────────────────
if dscl . -read "/Users/$TEST_USER" >/dev/null 2>&1; then
  echo "User $TEST_USER already exists."
  echo "Run 'sudo bash $0 --cleanup' first to remove it."
  exit 1
fi

# ── Generate password ────────────────────────────────────
# 8-14 chars, at least one #, 3-5 numbers, rest alphanumeric
generate_password() {
  local num_count=$((RANDOM % 3 + 3))        # 3-5 numbers
  local total_len=$((RANDOM % 7 + 8))        # 8-14 total
  local alpha_count=$((total_len - num_count - 1))  # -1 for the #

  local nums=""
  for ((i = 0; i < num_count; i++)); do
    nums+="$((RANDOM % 10))"
  done

  local alphas=""
  local chars="abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ"
  for ((i = 0; i < alpha_count; i++)); do
    alphas+="${chars:$((RANDOM % ${#chars})):1}"
  done

  # Combine: alphas + # + nums, then shuffle
  local combined="${alphas}#${nums}"
  echo "$combined" | fold -w1 | sort -R | tr -d '\n'
}

PASSWORD="$(generate_password)"

# ── Create user ──────────────────────────────────────────
echo "Creating test user: $TEST_USER"

dscl . -create "/Users/$TEST_USER"
dscl . -create "/Users/$TEST_USER" UserShell /bin/zsh
dscl . -create "/Users/$TEST_USER" RealName "Bootstrap Test"
dscl . -create "/Users/$TEST_USER" UniqueID "$TEST_UID"
dscl . -create "/Users/$TEST_USER" PrimaryGroupID 20
dscl . -create "/Users/$TEST_USER" NFSHomeDirectory "/Users/$TEST_USER"
dscl . -passwd "/Users/$TEST_USER" "$PASSWORD"

# Allow admin (needed for brew, sudo)
dscl . -append /Groups/admin GroupMembership "$TEST_USER"

mkdir -p "/Users/$TEST_USER"
chown "$TEST_USER":staff "/Users/$TEST_USER"

echo ""
echo "════════════════════════════════════════════════"
echo "  Test user created"
echo "════════════════════════════════════════════════"
echo ""
echo "  Username:  $TEST_USER"
echo "  Password:  $PASSWORD"
echo ""
echo "  Log in as this user, then run:"
echo ""
echo "    git clone $REPO_URL /tmp/bootstrap && cd /tmp/bootstrap && bash install.local.sh"
echo ""
echo "  When done, clean up from your main account:"
echo ""
echo "    sudo bash test/smoke.mac.sh --cleanup"
echo ""
echo "════════════════════════════════════════════════"
