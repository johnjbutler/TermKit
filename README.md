# TermKit 🚀

**A fully equipped setup script to install, configure, and deploy beautiful developer shells in seconds.**

TermKit automates the entire process of transforming your terminal from basic to breathtaking. No manual configuration, no hunting for themes, no complicated setups—just run the script and get a production-ready, aesthetically polished terminal environment instantly.

Perfect for developers who want their terminal to look as good as their code.

---

## ✨ What TermKit Does

TermKit is a complete terminal transformation toolkit that:

- **Installs** all essential CLI power tools automatically
- **Configures** your shell with optimized aliases and shortcuts
- **Customizes** your terminal with the beautiful Catppuccin Mocha theme
- **Deploys** a fully functional setup in under 60 seconds
- **Guarantees** a gorgeous, production-ready terminal with zero manual tweaking

Everything is automated. Everything is backed up. Everything just works.

---

## 🚀 Quick Start

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/termkit.git
   cd termkit
   ```

2. **Run the setup scripts**
   ```bash
   chmod +x install.sh
   ./install
   ```
      This script manually does the follwing:
      ```bash
      chmod +x ghostty-setup-catppuccin.sh terminal-aesthetic-setup.sh
      ./ghostty-setup-catppuccin.sh
      ./terminal-aesthetic-setup.sh
      ```

4. **Reload your shell**
   ```bash
   source ~/.zshrc
   ```

5. **Enjoy your beautiful terminal**
   ```bash
   neofetch
   ll
   ```

---

## 📁 Repository Structure

```
termkit/
├── configs/
│   └── config                      # Ghostty configuration
├── themes/
│   └── catppuccin-mocha.conf      # Catppuccin Mocha theme
├── ghostty-setup-catppuccin.sh    # Ghostty + theme installer
├── terminal-aesthetic-setup.sh     # Power tools installer
├── TUTORIAL.md                     # Complete reference guide
└── README.md                       # This file
```

---

**Built with ❤️ for developers who care about their tools**

*Your terminal is where you spend most of your day. It should look amazing.*
