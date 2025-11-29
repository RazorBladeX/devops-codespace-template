#!/usr/bin/env bash
# lazymode installer - Sets up lazymode in the user's home directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAZYMODE_HOME="$HOME/.lazymode"

echo "🦥 Installing lazymode..."

# Create lazymode directory in home
mkdir -p "$LAZYMODE_HOME"

# Copy files
cp -r "$SCRIPT_DIR"/* "$LAZYMODE_HOME/"

# Make executable
chmod +x "$LAZYMODE_HOME/menu.sh"
chmod +x "$LAZYMODE_HOME/install.sh"

# Add alias to shell config files
add_alias() {
    local rc_file="$1"
    local alias_line='alias lazymode="bash $HOME/.lazymode/menu.sh"'
    
    if [[ -f "$rc_file" ]]; then
        if ! grep -q "alias lazymode=" "$rc_file" 2>/dev/null; then
            echo "" >> "$rc_file"
            echo "# lazymode - The ultimate lazy-dev TUI menu" >> "$rc_file"
            echo "$alias_line" >> "$rc_file"
            echo "✅ Added alias to $rc_file"
        else
            echo "ℹ️  Alias already exists in $rc_file"
        fi
    fi
}

# Add to bash
if [[ -f "$HOME/.bashrc" ]]; then
    add_alias "$HOME/.bashrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    add_alias "$HOME/.bash_profile"
fi

# Add to zsh
if [[ -f "$HOME/.zshrc" ]]; then
    add_alias "$HOME/.zshrc"
fi

echo ""
echo "✅ lazymode installed successfully!"
echo ""
echo "To use lazymode:"
echo "  1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
echo "  2. Run: lazymode"
echo ""
echo "Or run directly: bash ~/.lazymode/menu.sh"
