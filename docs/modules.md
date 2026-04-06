# Modules

Each module is a self-contained script responsible for one tool or concern. Modules are called by the Stage 1 orchestrator in dependency order.

## Platform Modules

### `modules/mac.sh`

- Installs Xcode Command Line Tools if missing.
- Installs Homebrew if missing.
- Installs all formulae from `packages/brew.txt` via `ensure_brew_package` (idempotent).
- Installs cask apps (iTerm2, VS Code) with existence checks.

### `modules/linux.sh`

- Runs `apt update`.
- Installs all packages from `packages/apt.txt` via `ensure_apt_package` (idempotent).
- Installs VS Code via snap if not present.

### `modules/windows.ps1`

- Installs Chocolatey if missing.
- Installs all packages from `packages/choco.txt`.
- Installs WSL with Ubuntu if not present.
- Clones the bootstrap repo into WSL and runs `install.local.sh`, which detects the WSL environment and adjusts behavior (skips snap VS Code, skips native Docker, runs `modules/wsl/linux.sh`).

### `modules/wsl/wsl-bootstrap.ps1`

- Enables Windows features: WSL, VirtualMachinePlatform, Hyper-V.
- Checks for pending reboots before and after.
- Installs/updates the WSL2 kernel.
- Sets WSL2 as default version.

### `modules/wsl/linux.sh`

WSL-specific setup that runs after the standard `linux.sh` module. Handles differences between native Linux and WSL:

- **systemd** — Enables systemd in `/etc/wsl.conf` if not already configured (requires WSL 2.0+).
- **VS Code** — Verifies that Windows VS Code is accessible via PATH interop (snap doesn't work in WSL).
- **Docker** — Detects Docker Desktop WSL integration. Native Docker install is skipped in WSL to avoid conflicts.
- **DNS** — Warns if `/etc/resolv.conf` is auto-generated and offers the fix.
- **PATH interop** — Notes that Windows PATH leaks into WSL by default and how to disable it.

## Dev Tool Modules

### `modules/common_dev.sh`

Verifies that critical tools (`git`, `gh`) are present after platform setup. Does not install — that's the platform module's job. Exists as a safety check.

### `modules/gh/gh.sh` / `gh.ps1`

Runs `gh auth login --web --git-protocol https` if `gh` is not already authenticated. Uses browser-based OAuth. Required for Stage 2 private repo access.

### `modules/python.sh` / `python.ps1`

| Tool | Mac/Linux | Windows |
|------|-----------|---------|
| Version manager | pyenv (via `pyenv.run`) | pyenv-win |
| Package manager | uv (via `astral.sh`) | uv (via PowerShell installer) |
| Versions installed | 3.11.9, 3.14-dev | 3.11.9, 3.14-dev |
| Global default | 3.11.9 | 3.11.9 |

Python is managed exclusively by pyenv — Homebrew Python packages are intentionally excluded from `brew.txt` to avoid conflicts.

## Cloud Modules

### `modules/cloud/cloud.sh` / `cloud.ps1`

Installs three cloud CLIs:

| CLI | Mac | Linux | Windows |
|-----|-----|-------|---------|
| AWS CLI | `brew install awscli` | Official zip installer | `choco install awscli` |
| Azure CLI | `brew install azure-cli` | Microsoft install script | `choco install azure-cli` |
| Google Cloud SDK | `brew install --cask google-cloud-sdk` | `sdk.cloud.google.com` | `choco install gcloudsdk` |

**Auth** is optional and controlled by environment variables:

| Variable | Effect |
|----------|--------|
| `DO_CLOUD_AUTH=1` | Runs interactive auth for all three |
| `DO_CLOUD_AUTH_AWS=1` | `aws configure` |
| `DO_CLOUD_AUTH_AZURE=1` | `az login` |
| `DO_CLOUD_AUTH_GCP=1` | `gcloud auth login && gcloud init` |

Without these variables set, only the CLIs are installed — no interactive prompts.

## Container Modules

### `modules/docker/mac.sh`

- Installs Colima, Docker CLI, and kubectl via Homebrew.
- Starts Colima with 4 CPUs, 8 GB RAM, and Kubernetes enabled (only if not already running).
- Sets the Docker context to Colima.

### `modules/docker/linux.sh`

- Installs Docker Engine via the official `get.docker.com` script.
- Adds the current user to the `docker` group (requires shell restart to take effect).
- **Skipped in WSL** — `install.local.sh` detects WSL and skips this module to avoid conflicts with Docker Desktop WSL integration.

### `modules/docker/windows.ps1`

- Runs the Docker Engine install script inside WSL.

### `modules/docker/vscode.sh`

Installs VS Code extensions for container development:

- `ms-azuretools.vscode-docker`
- `ms-vscode-remote.remote-containers`
- `ms-vscode-remote.remote-wsl`

## Stage 2

### `modules/stage2/stage2.sh` / `stage2.ps1`

- Checks for `BOOTSTRAP_STAGE2_REPO` env var. Exits cleanly if not set.
- Verifies `gh` is authenticated.
- Clones the private repo to a temp directory via `gh repo clone`.
- Runs `install.sh` (or `install.ps1`) from the cloned repo.
- Cleans up the temp directory.
