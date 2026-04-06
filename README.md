🚀 Bootstrap v0.1

A cross-platform, idempotent development environment bootstrapper for macOS, Linux/WSL, and Windows.

This project provides a clean, repeatable way to go from a fresh machine → fully configured dev environment using a single command.

⸻

✨ Features

🧱 Core
	•	Cross-platform support:
	•	macOS
	•	Linux (Ubuntu/Debian)
	•	Windows (with WSL)
	•	Idempotent (safe to re-run anytime)
	•	Zero secrets in public repo
	•	Modular architecture

⸻

🛠️ Developer Tooling
	•	Git
	•	GitHub CLI (gh) with browser auth
	•	Visual Studio Code
	•	Terminal setup:
	•	macOS → iTerm2
	•	Windows → Windows Terminal

⸻

🐍 Python Environment
	•	pyenv for version management
	•	uv for fast package + environment management
	•	Installed versions:
	•	Python 3.11
	•	Python 3.14 (dev/latest)

⸻

🐳 Containers (No Docker Desktop)
	•	macOS:
	•	Colima (Docker runtime)
	•	Local Kubernetes cluster
	•	Linux / WSL:
	•	Native Docker Engine
	•	Windows:
	•	Docker runs inside WSL

⸻

☁️ Cloud CLIs
	•	AWS CLI (aws)
	•	Azure CLI (az)
	•	Google Cloud SDK (gcloud)
	•	Optional interactive auth via environment variables

⸻

🔐 Stage 2 (Private Extensions)
	•	Optional private repo execution
	•	Uses authenticated gh
	•	Keeps secrets out of public repo
	•	Fully re-runnable

⸻

⚡ Quick Start

macOS / Linux
```
curl -fsSL https://raw.githubusercontent.com/vakermit/bootstrap/main/install.sh | bash
```

⸻

Windows (PowerShell)
```
iex (irm https://raw.githubusercontent.com/vakermit/bootstrap/main/install.ps1)
```

⸻

🧠 How It Works

Stage 0 (Entrypoint)
	•	Runs from curl / iex
	•	Ensures git is installed
	•	Clones this repo into a temporary directory
	•	Logs output to:

~/bootstrap.log


⸻

Stage 1 (Core Bootstrap)
	•	Installs package manager:
	•	macOS → Homebrew
	•	Linux → apt
	•	Windows → Chocolatey
	•	Installs base tooling:
	•	git, gh, vscode
	•	Configures terminals

⸻

Stage 2 (Optional Private Layer)

If configured, clones and runs a private repo:

export BOOTSTRAP_STAGE2_REPO=your-org/private-bootstrap

Optional branch:

export BOOTSTRAP_STAGE2_REF=main


⸻

🏗️ Project Structure

```
bootstrap/
├── install.sh              # Stage 0 (curl entrypoint)
├── install.ps1            # Stage 0 (Windows entrypoint)
├── install.local.sh       # Stage 1 (main logic)
├── install.local.ps1
├── core/
│   └── utils.sh
├── modules/
│   ├── mac.sh
│   ├── linux.sh
│   ├── common_dev.sh
│   ├── python.sh
│   ├── gh/
│   │   ├── gh.sh
│   │   └── gh.ps1
│   ├── docker/
│   │   ├── mac.sh
│   │   ├── linux.sh
│   │   ├── windows.ps1
│   │   └── vscode.sh
│   ├── cloud/
│   │   ├── cloud.sh
│   │   └── cloud.ps1
│   └── stage2/
│       ├── stage2.sh
│       └── stage2.ps1
├── packages/
│   ├── brew.txt
│   ├── apt.txt
│   └── choco.txt
└── .gitignore
```

⸻

🔁 Idempotency

This project is designed to be safely re-run:
	•	Checks before installing packages
	•	Skips existing tools
	•	Updates repos instead of recloning
	•	Avoids overwriting configs

⸻

🧾 Logging

All output is logged to:

~/bootstrap.log

Useful for:
	•	debugging failures
	•	auditing installs
	•	rerun verification

⸻

🔐 Security Model
	•	No secrets stored in repo
	•	Authentication handled via gh
	•	Private repos accessed securely
	•	HTTPS enforced for git operations

⸻

⚙️ Configuration

Stage 2 Repo

export BOOTSTRAP_STAGE2_REPO=your-org/private-bootstrap

Optional Branch

export BOOTSTRAP_STAGE2_REF=dev

Cloud Auth

export DO_CLOUD_AUTH=1              # auth all three (aws, az, gcloud)

Or individually:

export DO_CLOUD_AUTH_AWS=1          # aws configure
export DO_CLOUD_AUTH_AZURE=1        # az login
export DO_CLOUD_AUTH_GCP=1          # gcloud auth login


⸻

🧪 Supported Environments

OS	Status
macOS	✅ Full support
Linux (Ubuntu/Debian)	✅ Full support
WSL	✅ Recommended
Windows (native)	⚠️ Uses WSL for most tooling


⸻

⚠️ Known Notes
	•	First run may require:
	•	macOS: accepting Xcode CLI prompt
	•	Windows: WSL install + restart
	•	Python 3.14 may be installed as dev version
	•	Docker group changes may require shell restart

⸻

🧭 Philosophy
	•	🔁 Reproducible environments
	•	🔐 Secure by default
	•	🧩 Modular and extensible
	•	🚫 Avoid vendor lock-in (no Docker Desktop)
	•	⚡ Fast developer onboarding

⸻

🚀 Future Improvements
	•	Profiles (dev, minimal, full)
	•	Dry-run mode
	•	Structured logging
	•	Config-driven module toggles
	•	Multi-repo Stage 2 support

⸻

🤝 Contributing

PRs welcome! Please keep:
	•	idempotency intact
	•	modules isolated
	•	no secrets or personal configs

⸻

📄 License

MIT (recommended)

⸻

🧠 Final Thought

This isn’t just a setup script—it’s a portable development platform foundation.

Run it on any machine and get back to building immediately.
:::