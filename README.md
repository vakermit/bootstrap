# Bootstrap

Cross-platform, idempotent development environment bootstrapper for **macOS**, **Linux/WSL**, and **Windows**.

One command takes a fresh machine to a fully configured dev environment.

## Quick Start

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/vakermit/bootstrap/main/install.sh | bash
```

**Windows (PowerShell)**

```powershell
iex (irm https://raw.githubusercontent.com/vakermit/bootstrap/main/install.ps1)
```

## What Gets Installed

| Category | Tools |
|----------|-------|
| **Dev Tooling** | Git, GitHub CLI (gh), VS Code, iTerm2 (mac), Windows Terminal |
| **Python** | pyenv, uv, Python 3.11, Python 3.14 |
| **Containers** | Colima + kubectl (mac), Docker Engine (linux), Docker via WSL (win) |
| **Cloud CLIs** | AWS CLI, Azure CLI, Google Cloud SDK |

All installs are idempotent — safe to re-run at any time.

## How It Works

The bootstrap runs in stages:

| Stage | What Happens |
|-------|-------------|
| **0 — Entry** | `curl`/`iex` ensures git is present, clones this repo to a temp dir, hands off to Stage 1 |
| **1 — Core** | Installs package manager, dev tools, python, cloud CLIs, containers, VS Code extensions |
| **2 — Private** | *(Optional)* Clones and runs a private repo for org-specific config, secrets, and tooling |

**`bsinstall`** — a standalone, repeatable installer for any GitHub repo that contains a `bootstrap.yml`. Run it anytime after the initial bootstrap to install additional repos:

```bash
bin/bsinstall.sh owner/repo [ref]
```

## Configuration

Set environment variables before running the installer to control optional behavior.

```bash
# Stage 2 — private repo (requires gh auth)
export BOOTSTRAP_STAGE2_REPO=your-org/private-bootstrap
export BOOTSTRAP_STAGE2_REF=main                          # optional, defaults to main

# Cloud auth — trigger interactive login during install
export DO_CLOUD_AUTH=1            # all three platforms
export DO_CLOUD_AUTH_AWS=1        # aws configure
export DO_CLOUD_AUTH_AZURE=1      # az login
export DO_CLOUD_AUTH_GCP=1        # gcloud auth login

# Temp directory cleanup — remove the Stage 0 clone dir after install
export BOOTSTRAP_CLEANUP=1        # default: keep temp dir
```

## Testing

```bash
# Linux — runs full install in a disposable Docker container
bash test/smoke.linux.sh

# macOS — creates a temporary user for a clean-slate install
sudo bash test/smoke.mac.sh            # creates user, prints credentials
sudo bash test/smoke.mac.sh --cleanup  # removes user when done
```

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture](docs/architecture.md) | Stage design, module system, execution flow |
| [Modules](docs/modules.md) | What each module installs and how |
| [bsinstall](docs/bsinstall.md) | Standalone repo installer — usage, bootstrap.yml format |
| [Configuration](docs/configuration.md) | Environment variables, package lists, customization |
| [Testing](docs/testing.md) | Smoke tests, adding new tests, CI |
| [Contributing](docs/contributing.md) | Guidelines for adding modules and submitting PRs |

## Project Structure

```
bootstrap/
├── install.sh                # Stage 0 entry (curl | bash)
├── install.ps1               # Stage 0 entry (iex)
├── bin/
│   └── bsinstall.sh          # Standalone repo installer (repeatable)
├── install.local.sh          # Stage 1 orchestrator (mac/linux)
├── install.local.ps1         # Stage 1 orchestrator (windows)
├── core/
│   └── utils.sh              # Shared shell helpers
├── modules/
│   ├── mac.sh                # macOS: Homebrew, Xcode CLT, casks
│   ├── linux.sh              # Linux: apt packages, VS Code
│   ├── common_dev.sh         # Cross-platform dev tool verification
│   ├── python.sh             # pyenv + uv (mac/linux)
│   ├── python.ps1            # pyenv-win + uv (windows)
│   ├── windows.ps1           # Chocolatey packages, WSL bootstrap
│   ├── gh/                   # GitHub CLI authentication
│   ├── cloud/                # AWS, Azure, GCP CLI install + auth
│   ├── docker/               # Container runtime per platform
│   ├── wsl/                  # WSL2 feature enablement (windows)
│   └── stage2/               # Private repo clone + execution
├── packages/
│   ├── brew.txt              # Homebrew formulae
│   ├── apt.txt               # Debian/Ubuntu packages
│   └── choco.txt             # Chocolatey packages
├── test/
│   ├── smoke.linux.sh        # Docker-based Linux smoke test
│   └── smoke.mac.sh          # Temporary user macOS smoke test
└── docs/
    ├── architecture.md
    ├── modules.md
    ├── configuration.md
    ├── testing.md
    └── contributing.md
```

## Supported Platforms

| OS | Status |
|----|--------|
| macOS (Apple Silicon & Intel) | Full support |
| Ubuntu / Debian | Full support |
| WSL 2 | Full support |
| Windows (native) | Partial — most tooling runs inside WSL |

## License

MIT
