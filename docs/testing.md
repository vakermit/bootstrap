# Testing

## Smoke Tests

Two smoke test scripts cover the Linux and macOS install paths without touching your primary user profile.

### Linux — Docker Container

```bash
bash test/smoke.linux.sh
```

**What it does:**

1. Pulls `ubuntu:24.04`.
2. Installs minimal prerequisites (`curl`, `git`, `sudo`, `unzip`).
3. Copies the repo into the container (bind mount is read-only).
4. Runs `install.local.sh`.
5. Checks for expected binaries: `git`, `gh`, `pyenv`, `uv`, `aws`, `az`, `gcloud`, `docker`, `code`.
6. Prints pass/fail counts.

The container is destroyed after the run (`--rm`). No state persists.

**Expected failures in container:** `code` (VS Code requires a display or snap), `docker` (docker-in-docker not configured). These are normal.

### macOS — Temporary User

```bash
# Create the test user (prints username + generated password)
sudo bash test/smoke.mac.sh

# Log in as the test user via Fast User Switching or log out
# Run the one-liner printed by the script

# Clean up from your main account
sudo bash test/smoke.mac.sh --cleanup
```

**What it does:**

1. Creates a local macOS user (`bootstraptest`) with a randomly generated password.
2. Adds the user to the admin group (needed for Homebrew and sudo).
3. Prints credentials and a one-liner to clone + run the installer.

The test user gets a clean home directory with no existing dotfiles, Homebrew, or pyenv — simulating a fresh machine.

**Password policy:** 8-14 characters, at least one `#`, 3-5 digits, remaining characters alphabetic, all shuffled randomly.

## Writing New Tests

Place test scripts in `test/`. Follow these conventions:

- Name: `smoke.{platform}.sh` for smoke tests, `test.{module}.sh` for unit-style module tests.
- Ensure the script is self-contained and cleans up after itself.
- Exit `0` on success, `1` on failure.
- Print clear pass/fail output.

## CI

The Linux smoke test is suitable for CI (GitHub Actions, etc.):

```yaml
jobs:
  smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash test/smoke.linux.sh
```
