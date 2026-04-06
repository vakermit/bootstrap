# Configuration

## Environment Variables

All configuration is done via environment variables. Set them before running the installer.

### Stage 2 (Private Repo)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `BOOTSTRAP_STAGE2_REPO` | No | *(none)* | GitHub repo in `owner/repo` format. If set, Stage 2 runs. |
| `BOOTSTRAP_STAGE2_REF` | No | `main` | Branch or tag to clone. |

Example:

```bash
export BOOTSTRAP_STAGE2_REPO=myorg/private-bootstrap
export BOOTSTRAP_STAGE2_REF=production
curl -fsSL https://raw.githubusercontent.com/vakermit/bootstrap/main/install.sh | bash
```

### Temp Directory Cleanup

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `BOOTSTRAP_CLEANUP` | No | *(unset)* | If set, removes the Stage 0 temp directory after install completes. If unset, the temp dir is kept and its path is printed. |

Example:

```bash
BOOTSTRAP_CLEANUP=1 bash <(curl -fsSL https://raw.githubusercontent.com/vakermit/bootstrap/main/install.sh)
```

### Cloud Authentication

| Variable | Effect |
|----------|--------|
| `DO_CLOUD_AUTH=1` | Interactive auth for AWS, Azure, and GCP |
| `DO_CLOUD_AUTH_AWS=1` | `aws configure` only |
| `DO_CLOUD_AUTH_AZURE=1` | `az login` only |
| `DO_CLOUD_AUTH_GCP=1` | `gcloud auth login && gcloud init` only |

These are opt-in. Without them, the installer installs CLIs silently with no interactive prompts.

## Package Lists

Package lists live in `packages/` and are read line-by-line by the platform modules.

| File | Used By | Format |
|------|---------|--------|
| `packages/brew.txt` | `modules/mac.sh` | One Homebrew formula per line |
| `packages/apt.txt` | `modules/linux.sh` | One apt package per line |
| `packages/choco.txt` | `modules/windows.ps1` | One Chocolatey package per line |

To add a tool to all platforms, add it to all three files. Blank lines and lines starting with `#` are ignored in `brew.txt` (the mac module skips them); the other modules pass lines directly to their package manager.

## Customization

### Adding a package

Add the package name to the appropriate file(s) in `packages/`. The installer picks it up automatically on next run.

### Adding a module

1. Create a script in `modules/` (or a subdirectory like `modules/mymodule/`).
2. Add a `bash modules/mymodule.sh` line to `install.local.sh` at the appropriate point in the execution order.
3. If it needs Windows support, create a `.ps1` equivalent and add it to `install.local.ps1`.
4. Source `core/utils.sh` if you need the shared helpers.

### Changing Python versions

Edit `modules/python.sh` and `modules/python.ps1`. The `pyenv install -s` flag skips versions that are already installed.
