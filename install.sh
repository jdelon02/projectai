#!/bin/bash

# ProjectAI Installation Script
# This script adds the projectai alias to your shell configuration

set -e

echo "🚀 Installing ProjectAI alias..."
echo "This runs ProjectAI directly from GitHub - no local files needed!"
echo ""

# Detect the shell
if [ -n "$ZSH_VERSION" ]; then
    SHELL_NAME="zsh"
    CONFIG_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_NAME="bash"
    CONFIG_FILE="$HOME/.bashrc"
else
    echo "⚠️  Shell detection failed. Defaulting to ~/.bashrc"
    SHELL_NAME="bash"
    CONFIG_FILE="$HOME/.bashrc"
fi

# The alias to add
ALIAS_LINE="alias projectai='curl -sSL https://raw.githubusercontent.com/jdelon02/projectai/main/projectai.sh | bash -s --'"

# Check if alias already exists
if grep -q "alias projectai=" "$CONFIG_FILE" 2>/dev/null; then
    echo "✓ ProjectAI alias already exists in $CONFIG_FILE"
else
    echo "📝 Adding ProjectAI alias to $CONFIG_FILE..."
    echo "" >> "$CONFIG_FILE"
    echo "# ProjectAI - AI-assisted project initialization" >> "$CONFIG_FILE"
    echo "$ALIAS_LINE" >> "$CONFIG_FILE"
    echo "✓ ProjectAI alias added to $CONFIG_FILE"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "To start using ProjectAI, either:"
echo "1. Restart your terminal, or"
echo "2. Run: source $CONFIG_FILE"
echo ""
echo "Then you can use:"
echo "  projectai drupal php mysql"
echo "  projectai react typescript tailwind"
echo "  projectai --help"
echo ""
echo "Prerequisites:"
echo "  Agent OS must be installed first:"
echo "  curl -sSL https://raw.githubusercontent.com/jdelon02/agent-os/main/setup.sh | bash"
