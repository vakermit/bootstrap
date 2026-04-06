# Architecture

## Design Principles

- **Idempotent** — Every operation checks before acting. Re-running the installer skips what's already done.
- **Modular** — Each tool or concern lives in its own script. Modules can be added, removed, or reordered without touching others.
- **Two-layer entry** — A minimal bash/PowerShell Stage 0 bootstraps just enough (git, clone) to hand off to the full Stage 1 orchestrator.
- **No secrets in repo** — Authentication happens interactively at runtime. Private configuration lives in a separate Stage 2 repo.

## Execution Flow

```
curl | bash  ──→  install.sh (Stage 0)
                    │
                    ├── ensure git exists
                    ├── clone repo to temp dir
                    └── exec install.local.sh (Stage 1)
                          │
                          ├── mac.sh / linux.sh      (platform packages)
                          ├── common_dev.sh           (verify dev tools)
                          ├── gh/gh.sh                (GitHub CLI auth)
                          ├── python.sh               (pyenv + uv)
                          ├── cloud/cloud.sh          (aws, az, gcloud)
                          ├── docker/{platform}.sh    (container runtime)
                          ├── docker/vscode.sh        (container extensions)
                          └── stage2/stage2.sh        (optional private repo)
```

The Windows path mirrors this with `.ps1` equivalents, plus a WSL preflight step.

## Stage 0 — Entry

**Files:** `install.sh`, `install.ps1`

Designed to be piped from `curl` or `iex`. Does the absolute minimum:

1. Ensures `git` is available (installs via xcode-select, apt, or chocolatey).
2. Clones this repo into a temporary directory.
3. Executes the Stage 1 orchestrator.
4. On exit, checks `BOOTSTRAP_CLEANUP`. If set, removes the temp directory. Otherwise prints the temp dir path so the user knows where it is.

All output is logged to `~/bootstrap.log`.

## Stage 1 — Core Bootstrap

**Files:** `install.local.sh`, `install.local.ps1`

The orchestrator. It:

1. Resolves its own directory (`cd "$(dirname "$0")"`) so relative module paths work regardless of how it was invoked.
2. Sources `core/utils.sh` for shared helpers.
3. Detects the OS and runs the appropriate platform module.
4. Runs each cross-platform module in dependency order.
5. Finishes with the optional Stage 2.

Modules are called via `bash modules/...` (subshell) so a failure in one module doesn't kill the orchestrator's `set -e` context — unless the module itself exits non-zero.

## Stage 2 — Private Extensions

**Files:** `modules/stage2/stage2.sh`, `modules/stage2/stage2.ps1`

Activated by setting `BOOTSTRAP_STAGE2_REPO`. Uses `gh repo clone` (authenticated) to pull a private repo into a temp directory, then runs its `install.sh` or `install.ps1`. The temp directory is cleaned up afterward.

This keeps secrets, org-specific config, and internal tooling out of the public repo.

## bsinstall — Standalone Repo Installer

**File:** `bin/bsinstall.sh`

A repeatable, standalone installer for any GitHub repo that ships a `bootstrap.yml`. Unlike Stage 2 (which runs once during the bootstrap flow), `bsinstall` can be run at any time to install or update additional repos.

Flow:

1. Authenticates via `gh` (prompts if needed).
2. Fetches `bootstrap.yml` from the target repo via the GitHub API.
3. Reads `install_dir` from the manifest.
4. Clones (or updates) the repo to `install_dir`.
5. Runs the repo's `install.sh` or `install.ps1`.

See [docs/bsinstall.md](bsinstall.md) for full documentation.

## Shared Helpers

**File:** `core/utils.sh`

Provides:

| Function | Purpose |
|----------|---------|
| `command_exists` | Check if a binary is on PATH |
| `ensure_brew_package` | Idempotent Homebrew install |
| `ensure_apt_package` | Idempotent apt install |
| `append_if_missing` | Append a line to a file only if not already present |

Modules that need these helpers source `core/utils.sh` at the top.
