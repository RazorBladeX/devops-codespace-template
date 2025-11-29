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

# Create lazymode command in /usr/local/bin for immediate availability
LAZYMODE_BIN="/usr/local/bin/lazymode"

# Create wrapper script content
read -r -d '' WRAPPER_SCRIPT << 'WRAPPER_EOF' || true
#!/usr/bin/env bash
exec bash "$HOME/.lazymode/menu.sh" "$@"
WRAPPER_EOF

# Validate target directory exists and is appropriate
if [[ -d "/usr/local/bin" ]]; then
    echo "📦 Installing lazymode command to $LAZYMODE_BIN..."

    if [[ -w "/usr/local/bin" ]]; then
        echo "$WRAPPER_SCRIPT" > "$LAZYMODE_BIN"
        chmod +x "$LAZYMODE_BIN"
        echo "✅ Installed lazymode command to $LAZYMODE_BIN"
    elif command -v sudo &>/dev/null; then
        echo "$WRAPPER_SCRIPT" | sudo tee "$LAZYMODE_BIN" > /dev/null
        sudo chmod +x "$LAZYMODE_BIN"
        echo "✅ Installed lazymode command to $LAZYMODE_BIN (with sudo)"
    else
        echo "⚠️  Could not install to $LAZYMODE_BIN (no write permission)"
        echo "   You can run lazymode with: bash ~/.lazymode/menu.sh"
    fi
else
    echo "⚠️  /usr/local/bin does not exist, skipping global install"
    echo "   You can run lazymode with: bash ~/.lazymode/menu.sh"
fi

# Add alias to shell config files (as backup/convenience)
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
echo "To use lazymode, simply run: lazymode"
