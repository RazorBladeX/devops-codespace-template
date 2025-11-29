# Org DevOps Golden Template

> **This is our official golden DevOps/SRE Codespace template** — production-ready, fully configured, and opinionated for maximum productivity.

## 🚀 Features

### Cloud CLIs & Infrastructure

| Tool | Description |
|------|-------------|
| **Docker-in-Docker** | Full Docker support inside the container |
| **Terraform** | Infrastructure as Code provisioning |
| **AWS CLI** | Amazon Web Services command-line interface |
| **Azure CLI** | Microsoft Azure command-line interface |
| **GitHub CLI** | GitHub command-line interface |

### Container Orchestration

| Tool | Description |
|------|-------------|
| **kubectl** | Kubernetes command-line tool (latest) |
| **Helm** | Kubernetes package manager (latest) |

### Development Tools

| Tool | Description |
|------|-------------|
| **Python** | Python runtime and pip |
| **Node.js** | Node.js runtime and npm |
| **Act** | Run GitHub Actions locally |
| **Common Utils** | Essential CLI utilities (git, curl, wget, etc.) |

### VS Code Extensions

| Extension | Purpose |
|-----------|---------|
| **HashiCorp Terraform** | Terraform syntax and validation |
| **Docker** | Docker file support and container management |
| **Azure CLI Tools** | Azure resource management |
| **AWS Toolkit** | AWS resource management |
| **GitLens** | Git supercharged |
| **YAML** | YAML language support |
| **Kubernetes** | Kubernetes cluster management |
| **GitHub Copilot** | AI pair programming |
| **GitHub Pull Requests** | PR and issue management |
| **Code Spell Checker** | Spelling validation |
| **Prettier** | Code formatting |
| **ShellCheck** | Shell script analysis |
| **Hadolint** | Dockerfile linting |
| **markdownlint** | Markdown linting |

## 🦥 lazymode — The Ultimate Lazy-Dev TUI Menu

Just type `lazymode` to open a beautiful terminal menu with all the common developer tasks:

| Option | Description |
|--------|-------------|
| 🎨 **Format All Files** | Run Prettier, Black, Ruff, gofmt, rustfmt, terraform fmt |
| 🔍 **Lint & Auto-Fix** | Run ESLint, Ruff, Flake8, golangci-lint, Clippy, ShellCheck |
| 🪝 **Run Pre-Commit** | Install hooks if missing, then run on all files |
| 🧪 **Run Tests** | Auto-detect and run npm test, pytest, go test, cargo test |
| 💾 **Git Commit** | Interactive conventional commit with type, scope, and description |
| 📝 **Create Draft PR** | Create a draft pull request with title and body |
| 📦 **Update Dependencies** | Update npm, pip, uv, go modules, cargo packages |
| 🧹 **Clean Artifacts** | Remove node_modules, __pycache__, target, dist, build |
| 🤖 **Copilot Explain** | Ask GitHub Copilot to explain the repository |
| 🔧 **Copilot Fix** | Ask GitHub Copilot to suggest fixes |
| 🔄 **Restart Codespace** | Restart the current Codespace |
| 🌐 **Open in Browser** | Open the GitHub repository in your browser |
| ⬆️ **Self-Update** | Update lazymode to the latest version |

### Smart Project Detection

lazymode automatically detects your project type (Python, Node.js, Go, Rust, Ruby, Java, Docker, Terraform) and shows relevant options based on what's in your repository.

### Installation

lazymode is automatically installed when the devcontainer starts. To manually install or update:

```bash
bash .lazymode/install.sh
```

## ⚙️ Pre-configured Settings

- **Auto-format on save** for all supported file types
- **Prettier** as default formatter (JSON, Markdown, JS/TS)
- **Terraform** language server with enhanced validation
- **YAML** schema validation and formatting
- **ShellCheck** for shell script linting
- **Hadolint** for Dockerfile best practices
- **markdownlint** for documentation quality
- **Trailing whitespace** automatically trimmed
- **Final newline** automatically inserted

## 📁 Repository Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json    # Dev container configuration
│   └── post-create.sh       # Post-creation setup script
├── .lazymode/
│   ├── menu.sh              # Main lazymode TUI menu
│   └── install.sh           # lazymode installer script
├── .vscode/
│   ├── settings.json        # VS Code workspace settings
│   └── extensions.json      # Recommended extensions
└── README.md
```

## 🏁 Getting Started

1. Click **"Use this template"** to create a new repository
2. Open in GitHub Codespaces or VS Code with Dev Containers
3. Wait for the container to build and post-create script to run
4. Start building infrastructure!
