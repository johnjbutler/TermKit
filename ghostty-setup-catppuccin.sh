#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error handler
error_exit() {
    echo -e "\n${RED}✗ Error: $1${NC}" >&2
    exit 1
}

# Spinner function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Progress bar function
progress_bar() {
    local current=$1
    local total=$2
    local step_name=$3
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    printf "\r\033[K"
    printf "[$current/$total] %s " "$step_name"
    printf "["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%%" "$percent"
}

TOTAL_STEPS=7
CURRENT_STEP=0

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    error_exit "Homebrew not found. Install from https://brew.sh"
fi

# Install figlet and lolcat for the banner
if ! command -v figlet &> /dev/null || ! command -v lolcat &> /dev/null; then
    brew install figlet lolcat > /dev/null 2>&1
fi

# Display fancy banner
cat << "BANNER" | lolcat

    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║   ████████╗███████╗██████╗ ███╗   ███╗██╗  ██╗██╗████████╗    ║
    ║   ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║ ██╔╝██║╚══██╔══╝    ║
    ║      ██║   █████╗  ██████╔╝██╔████╔██║█████╔╝ ██║   ██║       ║
    ║      ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██╔═██╗ ██║   ██║       ║
    ║      ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║  ██╗██║   ██║       ║
    ║      ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝   ╚═╝       ║
    ║                                                               ║
    ║                         By: Jack Butler                       ║
    ║                                                               ║
    ║                 ⚡ STEP 1: Terminal Emulator ⚡                 ║
    ║              Installing Ghostty with Catppuccin               ║
    ║                GPU-Accelerated • Blur • Transparency          ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝

BANNER
echo ""

# Step 1: Check/Install Ghostty
((CURRENT_STEP++))
progress_bar $CURRENT_STEP $TOTAL_STEPS "Checking Ghostty installation"
if ! command -v ghostty &> /dev/null; then
    printf "\n"
    echo "   Installing Ghostty..."
    if brew install --cask ghostty > /tmp/ghostty-install.log 2>&1; then
        echo "   ✓ Ghostty installed"
    else
        error_exit "Failed to install Ghostty. Check /tmp/ghostty-install.log"
    fi
else
    echo " ✓"
fi

# Step 2: Upgrade Ghostty
((CURRENT_STEP++))
progress_bar $CURRENT_STEP $TOTAL_STEPS "Upgrading Ghostty"
if brew upgrade --cask ghostty > /tmp/ghostty-upgrade.log 2>&1; then
    echo " ✓"
else
    # Upgrade can "fail" if already up to date, that's fine
    echo " ✓"
fi

# Step 3: Create directories
((CURRENT_STEP++))
progress_bar $CURRENT_STEP $TOTAL_STEPS "Creating config directories"
if mkdir -p ~/.config/ghostty/themes 2>/dev/null; then
    sleep 0.3
    echo " ✓"
else
    error_exit "Failed to create config directories"
fi

# Step 4: Copy theme from repo
((CURRENT_STEP++))
progress_bar $CURRENT_STEP $TOTAL_STEPS "Installing Catppuccin theme"
if [ -f "$SCRIPT_DIR/themes/catppuccin-mocha.conf" ]; then
    cp "$SCRIPT_DIR/themes/catppuccin-mocha.conf" ~/.config/ghostty/themes/
    echo " ✓"
else
    error_exit "Theme file not found. Make sure themes/catppuccin-mocha.conf exists in the repo."
fi

# Step 5: Copy config from repo
((CURRENT_STEP++))
progress_bar $CURRENT_STEP $TOTAL_STEPS "Installing Ghostty configuration"
if [ -f "$SCRIPT_DIR/configs/config" ]; then
    cp "$SCRIPT_DIR/configs/config" ~/.config/ghostty/config
    sleep 0.3
    echo " ✓"
else
    error_exit "Config file not found. Make sure configs/config exists in the repo."
fi

# Step 6: Install eza
((CURRENT_STEP++))
progress_bar $CURRENT_STEP $TOTAL_STEPS "Installing eza for colors"
if ! command -v eza &> /dev/null; then
    printf "\n"
    echo "   Installing eza..."
    if brew install eza > /tmp/eza-install.log 2>&1; then
        echo "   ✓ eza installed"
    else
        echo -e "   ${YELLOW}⚠ Warning: eza installation failed (non-critical)${NC}"
    fi
else
    echo " ✓"
fi

# Add eza alias (non-critical)
if [ -f ~/.zshrc ]; then
    if ! grep -q "alias ls=\"eza --icons\"" ~/.zshrc 2>/dev/null; then
        echo 'alias ls="eza --icons"' >> ~/.zshrc
    fi
else
    echo -e "${YELLOW}⚠ Warning: ~/.zshrc not found, skipping eza alias${NC}"
fi

# Step 7: Restart Ghostty
((CURRENT_STEP++))
progress_bar $CURRENT_STEP $TOTAL_STEPS "Restarting Ghostty"
killall Ghostty 2>/dev/null || true
sleep 1
if open -a Ghostty 2>/dev/null; then
    sleep 0.5
    echo " ✓"
else
    error_exit "Failed to launch Ghostty"
fi

echo ""
echo ""
cat << "SUCCESS" | lolcat

    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║                  ✨ TERMKIT STEP 1 COMPLETE ✨                ║
    ║                        You Leveled Up!                        ║
    ║              █████████████████████████████████                ║
    ║              █▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█                ║
    ║              █▓▓▓▓▓ Ghostty Configured ▓▓▓█                ║
    ║              █▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█                ║
    ║              █████████████████████████████████                ║
    ║                                                               ║
    ║              Terminal emulator ready 🚀                      ║
    ║            Continue to install power tools...                ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝

SUCCESS
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  --> Click Enter to install TermKit UI/UX components."
echo ""
echo "Your Ghostty terminal should now have:"
echo "  • Catppuccin Mocha theme"
echo "  • Background blur and transparency"
echo "  • Colorful directory listings with icons"
echo ""
echo "Logs saved to /tmp/ghostty-*.log if needed"
