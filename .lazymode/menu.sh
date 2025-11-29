#!/usr/bin/env bash
# lazymode - The ultimate lazy-dev TUI menu
# https://github.com/charmbracelet/gum

set -e

LAZYMODE_VERSION="1.0.0"
LAZYMODE_DIR="${LAZYMODE_DIR:-$HOME/.lazymode}"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if gum is installed
check_gum() {
    if ! command -v gum &>/dev/null; then
        echo -e "${RED}Error: gum is not installed.${NC}"
        echo -e "${YELLOW}Installing gum...${NC}"
        install_gum
    fi
}

# Install gum
install_gum() {
    if command -v apt-get &>/dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt-get update && sudo apt-get install -y gum
    elif command -v brew &>/dev/null; then
        brew install gum
    else
        echo -e "${RED}Cannot install gum. Please install it manually: https://github.com/charmbracelet/gum${NC}"
        exit 1
    fi
}

# Detect project type
detect_project_type() {
    local types=()
    
    [[ -f "$REPO_ROOT/package.json" ]] && types+=("node")
    [[ -f "$REPO_ROOT/pyproject.toml" || -f "$REPO_ROOT/setup.py" || -f "$REPO_ROOT/requirements.txt" ]] && types+=("python")
    [[ -f "$REPO_ROOT/go.mod" ]] && types+=("go")
    [[ -f "$REPO_ROOT/Cargo.toml" ]] && types+=("rust")
    [[ -f "$REPO_ROOT/Gemfile" ]] && types+=("ruby")
    [[ -f "$REPO_ROOT/pom.xml" || -f "$REPO_ROOT/build.gradle" ]] && types+=("java")
    [[ -f "$REPO_ROOT/Dockerfile" || -f "$REPO_ROOT/docker-compose.yml" ]] && types+=("docker")
    [[ -d "$REPO_ROOT/.terraform" || -n "$(find "$REPO_ROOT" -maxdepth 2 -name '*.tf' 2>/dev/null | head -1)" ]] && types+=("terraform")
    
    echo "${types[@]}"
}

# Show header
show_header() {
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "1 2" \
        '🦥 LAZYMODE' "v${LAZYMODE_VERSION}" '' 'The Ultimate Lazy-Dev Menu'
    
    local project_types
    project_types=$(detect_project_type)
    if [[ -n "$project_types" ]]; then
        echo -e "${CYAN}Detected: ${project_types}${NC}"
    fi
    echo ""
}

# Format all files
format_all() {
    gum spin --spinner dot --title "Formatting files..." -- sleep 1
    
    local formatted=false
    
    # Prettier (JS/TS/JSON/MD/etc.)
    if [[ -f "$REPO_ROOT/package.json" ]] && command -v npx &>/dev/null; then
        if npx prettier --version &>/dev/null; then
            echo -e "${BLUE}Running Prettier...${NC}"
            npx prettier --write . 2>/dev/null || true
            formatted=true
        fi
    fi
    
    # Black (Python)
    if command -v black &>/dev/null; then
        echo -e "${BLUE}Running Black...${NC}"
        black . 2>/dev/null || true
        formatted=true
    fi
    
    # Ruff (Python)
    if command -v ruff &>/dev/null; then
        echo -e "${BLUE}Running Ruff format...${NC}"
        ruff format . 2>/dev/null || true
        formatted=true
    fi
    
    # Go fmt
    if [[ -f "$REPO_ROOT/go.mod" ]] && command -v gofmt &>/dev/null; then
        echo -e "${BLUE}Running gofmt...${NC}"
        gofmt -w . 2>/dev/null || true
        formatted=true
    fi
    
    # Rust fmt
    if [[ -f "$REPO_ROOT/Cargo.toml" ]] && command -v cargo &>/dev/null; then
        echo -e "${BLUE}Running cargo fmt...${NC}"
        cargo fmt 2>/dev/null || true
        formatted=true
    fi
    
    # Terraform fmt
    if command -v terraform &>/dev/null && [[ -n "$(find . -name '*.tf' 2>/dev/null | head -1)" ]]; then
        echo -e "${BLUE}Running terraform fmt...${NC}"
        terraform fmt -recursive 2>/dev/null || true
        formatted=true
    fi
    
    if [[ "$formatted" == "true" ]]; then
        gum style --foreground 82 "✅ Formatting complete!"
    else
        gum style --foreground 214 "⚠️  No formatters found/applicable"
    fi
}

# Lint and auto-fix
lint_fix() {
    gum spin --spinner dot --title "Running linters..." -- sleep 1
    
    local linted=false
    
    # ESLint
    if [[ -f "$REPO_ROOT/package.json" ]] && command -v npx &>/dev/null; then
        if npx eslint --version &>/dev/null 2>&1; then
            echo -e "${BLUE}Running ESLint...${NC}"
            npx eslint . --fix 2>/dev/null || true
            linted=true
        fi
    fi
    
    # Ruff (Python)
    if command -v ruff &>/dev/null; then
        echo -e "${BLUE}Running Ruff check...${NC}"
        ruff check . --fix 2>/dev/null || true
        linted=true
    fi
    
    # Flake8 (Python)
    if command -v flake8 &>/dev/null; then
        echo -e "${BLUE}Running Flake8...${NC}"
        flake8 . 2>/dev/null || true
        linted=true
    fi
    
    # golangci-lint
    if [[ -f "$REPO_ROOT/go.mod" ]] && command -v golangci-lint &>/dev/null; then
        echo -e "${BLUE}Running golangci-lint...${NC}"
        golangci-lint run --fix 2>/dev/null || true
        linted=true
    fi
    
    # Clippy (Rust)
    if [[ -f "$REPO_ROOT/Cargo.toml" ]] && command -v cargo &>/dev/null; then
        echo -e "${BLUE}Running Clippy...${NC}"
        cargo clippy --fix --allow-dirty 2>/dev/null || true
        linted=true
    fi
    
    # ShellCheck
    if command -v shellcheck &>/dev/null; then
        echo -e "${BLUE}Running ShellCheck...${NC}"
        find . -name "*.sh" -type f -exec shellcheck {} \; 2>/dev/null || true
        linted=true
    fi
    
    # Terraform validate
    if command -v terraform &>/dev/null && [[ -n "$(find . -name '*.tf' 2>/dev/null | head -1)" ]]; then
        echo -e "${BLUE}Running terraform validate...${NC}"
        terraform validate 2>/dev/null || true
        linted=true
    fi
    
    if [[ "$linted" == "true" ]]; then
        gum style --foreground 82 "✅ Linting complete!"
    else
        gum style --foreground 214 "⚠️  No linters found/applicable"
    fi
}

# Run pre-commit
run_precommit() {
    if ! command -v pre-commit &>/dev/null; then
        echo -e "${YELLOW}Installing pre-commit...${NC}"
        pip install pre-commit 2>/dev/null || pip3 install pre-commit
    fi
    
    if [[ ! -f "$REPO_ROOT/.pre-commit-config.yaml" ]]; then
        gum style --foreground 214 "⚠️  No .pre-commit-config.yaml found"
        if gum confirm "Create a sample pre-commit config?"; then
            cat > "$REPO_ROOT/.pre-commit-config.yaml" << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-added-large-files
EOF
            echo -e "${GREEN}Created .pre-commit-config.yaml${NC}"
        else
            return
        fi
    fi
    
    echo -e "${BLUE}Installing pre-commit hooks...${NC}"
    pre-commit install
    
    echo -e "${BLUE}Running pre-commit on all files...${NC}"
    pre-commit run --all-files || true
    
    gum style --foreground 82 "✅ Pre-commit complete!"
}

# Run tests
run_tests() {
    gum spin --spinner dot --title "Detecting test framework..." -- sleep 1
    
    local tested=false
    
    # Node.js
    if [[ -f "$REPO_ROOT/package.json" ]]; then
        if grep -q '"test"' "$REPO_ROOT/package.json" 2>/dev/null; then
            echo -e "${BLUE}Running npm test...${NC}"
            npm test 2>/dev/null || true
            tested=true
        fi
    fi
    
    # Python pytest
    if command -v pytest &>/dev/null; then
        echo -e "${BLUE}Running pytest...${NC}"
        pytest 2>/dev/null || true
        tested=true
    fi
    
    # Python unittest
    if [[ -d "$REPO_ROOT/tests" ]] && ! command -v pytest &>/dev/null; then
        echo -e "${BLUE}Running python unittest...${NC}"
        python -m unittest discover 2>/dev/null || true
        tested=true
    fi
    
    # Go tests
    if [[ -f "$REPO_ROOT/go.mod" ]]; then
        echo -e "${BLUE}Running go test...${NC}"
        go test ./... 2>/dev/null || true
        tested=true
    fi
    
    # Rust tests
    if [[ -f "$REPO_ROOT/Cargo.toml" ]]; then
        echo -e "${BLUE}Running cargo test...${NC}"
        cargo test 2>/dev/null || true
        tested=true
    fi
    
    if [[ "$tested" == "true" ]]; then
        gum style --foreground 82 "✅ Tests complete!"
    else
        gum style --foreground 214 "⚠️  No test framework detected"
    fi
}

# Git commit with nice UI
git_commit() {
    cd "$REPO_ROOT"
    
    # Check for changes
    if [[ -z "$(git status --porcelain)" ]]; then
        gum style --foreground 214 "⚠️  No changes to commit"
        return
    fi
    
    echo -e "${BLUE}Current changes:${NC}"
    git status --short
    echo ""
    
    # Stage files
    if gum confirm "Stage all changes?"; then
        git add -A
    else
        echo "Select files to stage:"
        local files=$(git status --porcelain | awk '{print $2}')
        local selected=$(echo "$files" | gum choose --no-limit)
        if [[ -n "$selected" ]]; then
            echo "$selected" | xargs git add
        fi
    fi
    
    # Commit type
    local commit_type=$(gum choose "feat" "fix" "docs" "style" "refactor" "test" "chore" "ci" "perf" "build")
    
    # Scope (optional)
    local scope=$(gum input --placeholder "scope (optional, press enter to skip)")
    
    # Summary
    local summary=$(gum input --placeholder "Summary of this change" --width 50)
    
    # Description (optional)
    local description=$(gum write --placeholder "Details of this change (optional, Ctrl+D when done)")
    
    # Build commit message
    local commit_msg
    if [[ -n "$scope" ]]; then
        commit_msg="${commit_type}(${scope}): ${summary}"
    else
        commit_msg="${commit_type}: ${summary}"
    fi
    
    if [[ -n "$description" ]]; then
        commit_msg="${commit_msg}

${description}"
    fi
    
    echo ""
    echo -e "${CYAN}Commit message:${NC}"
    echo "$commit_msg"
    echo ""
    
    if gum confirm "Commit with this message?"; then
        git commit -m "$commit_msg"
        gum style --foreground 82 "✅ Committed successfully!"
    else
        gum style --foreground 214 "❌ Commit cancelled"
    fi
}

# Create draft PR
create_pr() {
    if ! command -v gh &>/dev/null; then
        gum style --foreground 196 "❌ GitHub CLI (gh) not installed"
        return
    fi
    
    # Check if authenticated
    if ! gh auth status &>/dev/null; then
        gum style --foreground 214 "⚠️  Not authenticated with GitHub CLI"
        echo "Run: gh auth login"
        return
    fi
    
    cd "$REPO_ROOT"
    
    # Get current branch
    local current_branch=$(git branch --show-current)
    local default_branch=$(git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}')
    
    if [[ "$current_branch" == "$default_branch" ]]; then
        gum style --foreground 214 "⚠️  You're on the default branch. Create a feature branch first."
        return
    fi
    
    # Push branch if needed
    if ! git rev-parse --verify "origin/$current_branch" &>/dev/null; then
        echo -e "${BLUE}Pushing branch to origin...${NC}"
        git push -u origin "$current_branch"
    fi
    
    # PR title
    local title=$(gum input --placeholder "PR Title" --width 60)
    
    # PR body
    local body=$(gum write --placeholder "Describe this PR (Ctrl+D when done)")
    
    if gum confirm "Create draft PR?"; then
        gh pr create --draft --title "$title" --body "$body"
        gum style --foreground 82 "✅ Draft PR created!"
    else
        gum style --foreground 214 "❌ PR creation cancelled"
    fi
}

# Update dependencies
update_deps() {
    gum spin --spinner dot --title "Updating dependencies..." -- sleep 1
    
    local updated=false
    
    # Node.js
    if [[ -f "$REPO_ROOT/package.json" ]]; then
        echo -e "${BLUE}Updating npm packages...${NC}"
        npm update 2>/dev/null || true
        updated=true
    fi
    
    # Python - pip
    if [[ -f "$REPO_ROOT/requirements.txt" ]]; then
        echo -e "${BLUE}Updating pip packages...${NC}"
        pip install --upgrade -r requirements.txt 2>/dev/null || \
            pip3 install --upgrade -r requirements.txt 2>/dev/null || true
        updated=true
    fi
    
    # Python - uv (only sync existing lock, don't overwrite requirements.txt)
    if command -v uv &>/dev/null && [[ -f "$REPO_ROOT/pyproject.toml" ]]; then
        echo -e "${BLUE}Updating with uv...${NC}"
        uv sync 2>/dev/null || uv pip install -e . 2>/dev/null || true
        updated=true
    fi
    
    # Go
    if [[ -f "$REPO_ROOT/go.mod" ]]; then
        echo -e "${BLUE}Updating Go modules...${NC}"
        go get -u ./... 2>/dev/null || true
        go mod tidy 2>/dev/null || true
        updated=true
    fi
    
    # Rust
    if [[ -f "$REPO_ROOT/Cargo.toml" ]]; then
        echo -e "${BLUE}Updating Cargo packages...${NC}"
        cargo update 2>/dev/null || true
        updated=true
    fi
    
    if [[ "$updated" == "true" ]]; then
        gum style --foreground 82 "✅ Dependencies updated!"
    else
        gum style --foreground 214 "⚠️  No dependency files found"
    fi
}

# Clean build artifacts
clean_artifacts() {
    gum spin --spinner dot --title "Cleaning build artifacts..." -- sleep 1
    
    local cleaned=false
    
    # Validate REPO_ROOT is a valid directory
    if [[ ! -d "$REPO_ROOT" ]] || [[ "$REPO_ROOT" == "/" ]]; then
        gum style --foreground 196 "❌ Invalid repository root: $REPO_ROOT"
        return
    fi
    
    # Node.js
    if [[ -d "$REPO_ROOT/node_modules" ]]; then
        echo -e "${BLUE}Removing node_modules...${NC}"
        rm -rf "$REPO_ROOT/node_modules"
        cleaned=true
    fi
    
    # Python __pycache__
    local pycache_dirs
    pycache_dirs=$(find "$REPO_ROOT" -type d -name "__pycache__" 2>/dev/null || true)
    if [[ -n "$pycache_dirs" ]]; then
        echo -e "${BLUE}Removing __pycache__ directories...${NC}"
        echo "$pycache_dirs" | xargs rm -rf 2>/dev/null || true
        cleaned=true
    fi
    
    # Python .egg-info
    local egg_dirs
    egg_dirs=$(find "$REPO_ROOT" -type d -name "*.egg-info" 2>/dev/null || true)
    if [[ -n "$egg_dirs" ]]; then
        echo -e "${BLUE}Removing .egg-info directories...${NC}"
        echo "$egg_dirs" | xargs rm -rf 2>/dev/null || true
        cleaned=true
    fi
    
    if [[ -d "$REPO_ROOT/.pytest_cache" ]]; then
        echo -e "${BLUE}Removing .pytest_cache...${NC}"
        rm -rf "$REPO_ROOT/.pytest_cache"
        cleaned=true
    fi
    
    # Rust
    if [[ -d "$REPO_ROOT/target" ]]; then
        echo -e "${BLUE}Removing Rust target directory...${NC}"
        rm -rf "$REPO_ROOT/target"
        cleaned=true
    fi
    
    # Go
    if command -v go &>/dev/null; then
        echo -e "${BLUE}Running go clean...${NC}"
        go clean -cache 2>/dev/null || true
        cleaned=true
    fi
    
    # .DS_Store files
    local ds_files
    ds_files=$(find "$REPO_ROOT" -name ".DS_Store" 2>/dev/null || true)
    if [[ -n "$ds_files" ]]; then
        echo -e "${BLUE}Removing .DS_Store files...${NC}"
        echo "$ds_files" | xargs rm -f 2>/dev/null || true
        cleaned=true
    fi
    
    # dist directories
    if [[ -d "$REPO_ROOT/dist" ]]; then
        echo -e "${BLUE}Removing dist directory...${NC}"
        rm -rf "$REPO_ROOT/dist"
        cleaned=true
    fi
    
    # build directories
    if [[ -d "$REPO_ROOT/build" ]]; then
        echo -e "${BLUE}Removing build directory...${NC}"
        rm -rf "$REPO_ROOT/build"
        cleaned=true
    fi
    
    if [[ "$cleaned" == "true" ]]; then
        gum style --foreground 82 "✅ Cleanup complete!"
    else
        gum style --foreground 214 "⚠️  Nothing to clean"
    fi
}

# Copilot explain repo
copilot_explain() {
    if ! command -v gh &>/dev/null; then
        gum style --foreground 196 "❌ GitHub CLI (gh) not installed"
        return
    fi
    
    if ! gh extension list | grep -q "gh-copilot"; then
        echo -e "${YELLOW}Installing GitHub Copilot CLI extension...${NC}"
        gh extension install github/gh-copilot 2>/dev/null || true
    fi
    
    echo -e "${MAGENTA}🤖 Asking Copilot to explain this repository...${NC}"
    echo ""
    
    # Get repo info
    local readme=""
    if [[ -f "$REPO_ROOT/README.md" ]]; then
        readme=$(head -100 "$REPO_ROOT/README.md")
    fi
    
    local files=$(find "$REPO_ROOT" -maxdepth 2 -type f -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.toml" 2>/dev/null | head -10)
    
    gh copilot explain "Explain this repository. Here is the README: $readme. Key config files found: $files" 2>/dev/null || \
        echo -e "${YELLOW}Copilot CLI not available. Try: gh extension install github/gh-copilot${NC}"
}

# Copilot fix
copilot_fix() {
    if ! command -v gh &>/dev/null; then
        gum style --foreground 196 "❌ GitHub CLI (gh) not installed"
        return
    fi
    
    if ! gh extension list | grep -q "gh-copilot"; then
        echo -e "${YELLOW}Installing GitHub Copilot CLI extension...${NC}"
        gh extension install github/gh-copilot 2>/dev/null || true
    fi
    
    echo -e "${MAGENTA}🤖 Asking Copilot to analyze and fix issues...${NC}"
    echo ""
    
    # Get recent errors
    local git_status=$(git status --short 2>/dev/null)
    
    gh copilot suggest "Analyze this repository and suggest fixes for any issues. Current git status: $git_status" 2>/dev/null || \
        echo -e "${YELLOW}Copilot CLI not available. Try: gh extension install github/gh-copilot${NC}"
}

# Restart codespace
restart_codespace() {
    if [[ -n "$CODESPACES" ]]; then
        if gum confirm "Restart this Codespace?"; then
            gh codespace restart 2>/dev/null || echo -e "${YELLOW}Use 'Codespaces: Rebuild Container' from VS Code command palette${NC}"
        fi
    else
        gum style --foreground 214 "⚠️  Not running in a GitHub Codespace"
    fi
}

# Open repo in browser
open_repo() {
    if command -v gh &>/dev/null; then
        gh repo view --web 2>/dev/null || echo -e "${YELLOW}Could not open repository${NC}"
    else
        local remote_url=$(git config --get remote.origin.url)
        if [[ -n "$remote_url" ]]; then
            # Convert SSH URL to HTTPS if needed
            remote_url=$(echo "$remote_url" | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
            echo -e "${CYAN}Repository URL: $remote_url${NC}"
            if command -v xdg-open &>/dev/null; then
                xdg-open "$remote_url" 2>/dev/null
            elif command -v open &>/dev/null; then
                open "$remote_url" 2>/dev/null
            fi
        fi
    fi
}

# Self-update
self_update() {
    echo -e "${BLUE}Checking for updates...${NC}"
    
    # Check if we're in a git repo with the lazymode source
    if [[ -d "$REPO_ROOT/.lazymode" ]]; then
        local source_dir="$REPO_ROOT/.lazymode"
    else
        gum style --foreground 214 "⚠️  Cannot find lazymode source directory"
        return
    fi
    
    # Copy latest version to home directory
    if [[ "$source_dir" != "$LAZYMODE_DIR" ]]; then
        echo -e "${BLUE}Updating lazymode from repository...${NC}"
        mkdir -p "$LAZYMODE_DIR"
        cp -r "$source_dir"/* "$LAZYMODE_DIR/"
        chmod +x "$LAZYMODE_DIR/menu.sh"
        gum style --foreground 82 "✅ lazymode updated!"
    else
        gum style --foreground 82 "✅ lazymode is up to date!"
    fi
}

# Main menu
main_menu() {
    check_gum
    
    while true; do
        clear
        show_header
        
        local choice=$(gum choose \
            "🎨 Format All Files" \
            "🔍 Lint & Auto-Fix" \
            "🪝 Run Pre-Commit" \
            "🧪 Run Tests" \
            "💾 Git Commit" \
            "📝 Create Draft PR" \
            "📦 Update All Dependencies" \
            "🧹 Clean Build Artifacts" \
            "🤖 Copilot: Explain This Repo" \
            "🔧 Copilot: Fix Everything" \
            "🔄 Restart Codespace" \
            "🌐 Open GitHub Repo in Browser" \
            "⬆️  Self-Update" \
            "❌ Exit")
        
        echo ""
        
        case "$choice" in
            "🎨 Format All Files")
                format_all
                ;;
            "🔍 Lint & Auto-Fix")
                lint_fix
                ;;
            "🪝 Run Pre-Commit")
                run_precommit
                ;;
            "🧪 Run Tests")
                run_tests
                ;;
            "💾 Git Commit")
                git_commit
                ;;
            "📝 Create Draft PR")
                create_pr
                ;;
            "📦 Update All Dependencies")
                update_deps
                ;;
            "🧹 Clean Build Artifacts")
                clean_artifacts
                ;;
            "🤖 Copilot: Explain This Repo")
                copilot_explain
                ;;
            "🔧 Copilot: Fix Everything")
                copilot_fix
                ;;
            "🔄 Restart Codespace")
                restart_codespace
                ;;
            "🌐 Open GitHub Repo in Browser")
                open_repo
                ;;
            "⬆️  Self-Update")
                self_update
                ;;
            "❌ Exit")
                gum style --foreground 212 "👋 See you later!"
                exit 0
                ;;
            *)
                exit 0
                ;;
        esac
        
        echo ""
        gum input --placeholder "Press Enter to continue..."
    done
}

# Run main menu
main_menu
