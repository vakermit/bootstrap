# bsinstall

A standalone, repeatable installer for any GitHub repo that ships a `bootstrap.yml` manifest. Use it to install private tooling, dotfiles, or project-specific environments — independently of the main bootstrap flow.

## Usage

```bash
bin/bsinstall.sh <owner/repo> [ref]
```

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `owner/repo` | Yes | — | GitHub repository in `owner/repo` format |
| `ref` | No | `main` | Branch, tag, or commit to install |

### Examples

```bash
# Install from main branch
bin/bsinstall.sh myorg/dev-environment

# Install a specific branch
bin/bsinstall.sh myorg/dev-environment production

# Install a tagged release
bin/bsinstall.sh myorg/dev-environment v2.1.0
```

## How It Works

1. **Authenticates** — Checks that `gh` is installed and authenticated. If not authenticated, launches `gh auth login` interactively.
2. **Fetches manifest** — Downloads `bootstrap.yml` from the target repo via the GitHub API (no clone needed yet).
3. **Reads `install_dir`** — Extracts the target directory from the manifest. Supports `~` expansion.
4. **Clones or updates** — If the directory exists with a `.git` folder, fetches and checks out the requested ref. Otherwise clones fresh. Backs up non-git leftovers from failed prior runs.
5. **Runs installer** — Executes `install.sh` (or `install.ps1`) from the cloned repo.

All output is logged to `~/bootstrap.log`.

## bootstrap.yml Format

The target repo must contain a `bootstrap.yml` at its root. Minimal example:

```yaml
install_dir: ~/tools/my-environment
```

| Field | Required | Description |
|-------|----------|-------------|
| `install_dir` | Yes | Where to clone the repo. Supports `~` for home directory. |

The manifest is parsed with `yq` if available, otherwise falls back to a portable `grep`/`sed` parser that handles quoted values and inline comments.

## Prerequisites

| Tool | Required | Purpose |
|------|----------|---------|
| `gh` | Yes | GitHub CLI — used for authentication and API access |
| `git` | Yes | Cloning and updating the target repo |
| `yq` | No | YAML parsing (falls back to grep/sed if absent) |

## Ref Handling

The `ref` argument flows through the entire process:

- **API fetch** — `bootstrap.yml` is fetched from the specified ref, not just `main`.
- **Clone** — `gh repo clone` uses `--branch <ref>`.
- **Update** — existing repos are checked out to the requested ref before pulling.

This means you can pin an install to a release tag and re-run it safely.

## Error Recovery

| Scenario | Behavior |
|----------|----------|
| Target dir exists but isn't a git repo | Backed up to `<dir>.bak.<timestamp>`, then cloned fresh |
| `gh` not authenticated | Interactive `gh auth login` is launched automatically |
| `bootstrap.yml` missing from repo | Exits with clear error message |
| `install_dir` missing from manifest | Exits with clear error message |
| No `install.sh` or `install.ps1` in repo | Exits with clear error message |

## Idempotency

Safe to re-run. On subsequent runs:

- Existing repos are updated (`git fetch` + `checkout`) instead of re-cloned.
- The target repo's own `install.sh` is responsible for its internal idempotency.
