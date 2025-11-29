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
