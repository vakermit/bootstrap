# Contributing

PRs are welcome. Please follow these guidelines.

## Principles

1. **Idempotency** — Every install operation must check before acting. Running the installer twice should produce no errors and no side effects.
2. **Module isolation** — Each module handles one tool or concern. Don't add unrelated installs to an existing module.
3. **No secrets** — Never commit API keys, tokens, passwords, or personal configuration. Use environment variables or Stage 2.
4. **Cross-platform parity** — If you add a tool, consider whether it applies to macOS, Linux, and Windows. Add platform-appropriate scripts for each.

## Adding a Module

1. Create your script in `modules/` (or a subdirectory for multi-file modules).
2. Source `core/utils.sh` at the top if you need shared helpers.
3. Use `set -e` for bash scripts, `$ErrorActionPreference = "Stop"` for PowerShell.
4. Add the module call to `install.local.sh` and/or `install.local.ps1` at the appropriate point in the execution order.
5. Update `docs/modules.md` with a description of what the module installs.
6. Test with `test/smoke.linux.sh` (and `test/smoke.mac.sh` if the module affects macOS).

## Adding a Package

Add the package name to the relevant file(s) in `packages/`:

| Platform | File |
|----------|------|
| macOS | `packages/brew.txt` |
| Linux | `packages/apt.txt` |
| Windows | `packages/choco.txt` |

No code changes needed — the platform modules read these files dynamically.

## Commit Messages

Use conventional style:

```
feat: add terraform module
fix: guard colima start behind status check
docs: add cloud auth examples
```

## Testing Your Changes

Run the smoke tests before submitting a PR:

```bash
bash test/smoke.linux.sh
```

If your change affects macOS-specific behavior, test with `smoke.mac.sh` on a temporary user account.
