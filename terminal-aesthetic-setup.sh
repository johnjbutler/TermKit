#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check Homebrew first
if ! command -v brew &> /dev/null; then
    echo -e "${RED}✗ Homebrew not found. Install from https://brew.sh${NC}"
    exit 1
fi

# Install figlet and lolcat for the banner
if ! command -v figlet &> /dev/null || ! command -v lolcat &> /dev/null; then
    echo "Installing banner tools..."
    brew install figlet lolcat > /dev/null 2>&1
fi

# Display fancy banner
cat << "BANNER" | lolcat

╔═══════════════════════════════════════════════════════════════╗
║                           TermKit                             ║
║                                                               ║
║          Terminal Aesthetic & Power Tools Setup              ║
║                 Making CLI Beautiful                          ║
╚═══════════════════════════════════════════════════════════════╝

BANNER
figlet -f banner "TermKit" | lolcat
echo ""

# Tools to install
declare -a tools=(
    "figlet:Figlet ASCII Art"
    "lolcat:Lolcat Rainbow Colors"
    "starship:Starship Prompt"
    "neofetch:Neofetch System Info"
    "cmatrix:CMatrix Animation"
    "eza:Eza (Better ls)"
    "bat:Bat (Better cat)"
    "fzf:Fuzzy Finder"
    "zoxide:Zoxide (Smart cd)"
    "tldr:TLDR Man Pages"
    "ripgrep:Ripgrep (Better grep)"
    "htop:Htop (Better top)"
)

TOTAL=${#tools[@]}
CURRENT=0

echo -e "${BLUE}Installing tools...${NC}\n"

for tool_info in "${tools[@]}"; do
    IFS=':' read -r tool_name tool_desc <<< "$tool_info"
    ((CURRENT++))
    
    echo -ne "[${CURRENT}/${TOTAL}] Installing ${tool_desc}... "
    
    if command -v "$tool_name" &> /dev/null; then
        echo -e "${GREEN}✓ Already installed${NC}"
    else
        if brew install "$tool_name" > /tmp/"${tool_name}"-install.log 2>&1; then
            echo -e "${GREEN}✓ Installed${NC}"
        else
            echo -e "${YELLOW}⚠ Failed (non-critical)${NC}"
        fi
    fi
done

# Special case for colorls (Ruby gem)
echo -ne "[Extra] Installing colorls... "
if gem list colorls -i &> /dev/null; then
    echo -e "${GREEN}✓ Already installed${NC}"
else
    if sudo gem install colorls > /tmp/colorls-install.log 2>&1; then
        echo -e "${GREEN}✓ Installed${NC}"
    else
        echo -e "${YELLOW}⚠ Failed (requires sudo)${NC}"
    fi
fi

echo ""
echo -e "${MAGENTA}Creating alias configuration...${NC}"

# Backup existing zshrc
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    echo -e "${GREEN}✓ Backed up existing .zshrc${NC}"
fi

# Create aliases file
cat << 'ALIASES' > ~/.zsh_aliases
# ═══════════════════════════════════════════════════════
# Terminal Aesthetic & Power Tools Aliases
# ═══════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────
# File Listing (eza & colorls)
# ─────────────────────────────────────────────────────
alias ls="eza --icons"                    # Basic eza
alias ll="eza -la --icons"                # Detailed list
alias lt="eza --tree --icons --level=2"   # Tree view (2 levels)
alias ltt="eza --tree --icons --level=3"  # Tree view (3 levels)
alias la="eza -a --icons"                 # Show hidden files

# Colorls alternatives (prefix with 'c')
alias cls="colorls --sd"                  # Colorls basic
alias cll="colorls -la --sd"              # Colorls detailed
alias clt="colorls --tree"                # Colorls tree

# ─────────────────────────────────────────────────────
# File Viewing (bat)
# ─────────────────────────────────────────────────────
alias cat="bat --style=auto"              # Cat with syntax highlighting
alias catp="bat --style=plain"            # Bat without line numbers
alias catt="bat --style=full"             # Bat with all decorations

# ─────────────────────────────────────────────────────
# Search & Navigation
# ─────────────────────────────────────────────────────
alias z="zoxide"                          # Smart cd
alias zi="zoxide query -i"                # Interactive zoxide
alias grep="rg"                           # Better grep
alias rg="rg --pretty"                    # Ripgrep with colors

# ─────────────────────────────────────────────────────
# System Monitoring
# ─────────────────────────────────────────────────────
alias top="htop"                          # Better top
alias processes="htop"                    # Alias for clarity

# ─────────────────────────────────────────────────────
# Quick Info & Fun
# ─────────────────────────────────────────────────────
alias sysinfo="neofetch"                  # System info
alias matrix="cmatrix -b"                 # Matrix effect
alias help="tldr"                         # Quick help

# ─────────────────────────────────────────────────────
# Utility Shortcuts
# ─────────────────────────────────────────────────────
alias reload="source ~/.zshrc"            # Reload zsh config
alias zshconfig="code ~/.zshrc"           # Edit zsh config (VS Code)
alias aliasconfig="code ~/.zsh_aliases"   # Edit aliases (VS Code)

# ─────────────────────────────────────────────────────
# Quick Switching Between Tools
# ─────────────────────────────────────────────────────
# Toggle between eza and colorls
switch_ls() {
    if alias ls 2>/dev/null | grep -q "eza"; then
        alias ls="colorls --sd"
        alias ll="colorls -la --sd"
        alias lt="colorls --tree"
        echo "Switched to colorls"
    else
        alias ls="eza --icons"
        alias ll="eza -la --icons"
        alias lt="eza --tree --icons --level=2"
        echo "Switched to eza"
    fi
}
alias switch="switch_ls"

# Use original commands (bypass aliases)
alias og_ls="/bin/ls"
alias og_cat="/bin/cat"
alias og_grep="/usr/bin/grep"
alias og_top="/usr/bin/top"
ALIASES

# Add initialization to .zshrc if not already present
if ! grep -q "source ~/.zsh_aliases" ~/.zshrc 2>/dev/null; then
    cat << 'ZSHRC_ADDITIONS' >> ~/.zshrc

# ═══════════════════════════════════════════════════════
# Terminal Aesthetic Setup
# ═══════════════════════════════════════════════════════

# Load aliases
source ~/.zsh_aliases

# Initialize Starship prompt
eval "$(starship init zsh)"

# Initialize zoxide (smart cd)
eval "$(zoxide init zsh)"

# Initialize fzf (fuzzy finder)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"

# Run neofetch on terminal start (optional - comment out if too slow)
# neofetch

ZSHRC_ADDITIONS
fi

echo -e "${GREEN}✓ Aliases configured${NC}"
echo ""

# Create starship config
mkdir -p ~/.config
cat << 'STARSHIP_CONFIG' > ~/.config/starship.toml
# Starship Configuration
format = """
[┌───────────────────>](bold green)
[│](bold green)$directory$git_branch$git_status
[└─>](bold green) """

[directory]
style = "bold cyan"
truncation_length = 3
truncate_to_repo = true

[git_branch]
symbol = " "
style = "bold purple"

[git_status]
style = "bold yellow"
ahead = "⇡${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
behind = "⇣${count}"

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"
STARSHIP_CONFIG

echo -e "${GREEN}✓ Starship configured${NC}"
echo ""

echo -e "\n╔═══════════════════════════════════════════════════════════════╗"
figlet -f banner "Success!" | lolcat
echo -e "║                                                               ║\n║              Setup Complete!                                  ║\n╚═══════════════════════════════════════════════════════════════╝\n"

echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Run: ${GREEN}source ~/.zshrc${NC}"
echo "  2. Try: ${GREEN}neofetch${NC}"
echo "  3. Try: ${GREEN}ls${NC} or ${GREEN}ll${NC}"
echo "  4. Try: ${GREEN}switch${NC} to toggle between eza and colorls"
echo ""
echo -e "${YELLOW}Quick Reference:${NC}"
echo "  ${CYAN}ls/ll/lt${NC}     - File listing (eza)"
echo "  ${CYAN}cls/cll/clt${NC}  - File listing (colorls)"
echo "  ${CYAN}cat${NC}          - View files with syntax highlighting"
echo "  ${CYAN}z <dir>${NC}      - Jump to directory"
echo "  ${CYAN}grep${NC}         - Search (ripgrep)"
echo "  ${CYAN}help <cmd>${NC}   - Quick help (tldr)"
echo "  ${CYAN}sysinfo${NC}      - System info (neofetch)"
echo "  ${CYAN}matrix${NC}       - Matrix animation"
echo "  ${CYAN}switch${NC}       - Toggle ls tools"
echo "  ${CYAN}og_ls${NC}        - Use original commands"
echo ""
echo -e "${GREEN}All aliases saved to: ~/.zsh_aliases${NC}"
echo -e "${GREEN}Backup saved to: ~/.zshrc.backup.*${NC}"
