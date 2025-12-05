#!/bin/bash

# TermKit Quick Installer
# Makes scripts executable and runs them in order

set -e

echo "🚀 TermKit Quick Installer"
echo "=========================="
echo ""

# Make scripts executable
echo "Making scripts executable..."
chmod +x ghostty-setup-catppuccin.sh
chmod +x terminal-aesthetic-setup.sh
echo "✓ Scripts are now executable"
echo ""

# Run Ghostty setup
echo "Running Ghostty setup..."
echo ""
./ghostty-setup-catppuccin.sh

echo ""
echo "Press Enter to continue to power tools setup..."
read

# Run terminal aesthetic setup
echo ""
echo "Running terminal aesthetic setup..."
echo ""
./terminal-aesthetic-setup.sh

echo ""
echo "════════════════════════════════════════════════"
echo "✅ TermKit installation complete!"
echo "════════════════════════════════════════════════"
echo ""
echo "Run this command to activate everything:"
echo "  source ~/.zshrc"
echo ""
echo "Then try:"
echo "  neofetch"
echo "  ll"
echo ""
