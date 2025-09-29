#!/usr/bin/env bash
# Quick setup script for installing nvim config on a new machine
# Usage: bash quick-setup.sh [--https]

set -euo pipefail

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No colour

# Configuration
REPO_SSH="git@github.com:go-bayes/nvim.git"
REPO_HTTPS="https://github.com/go-bayes/nvim.git"
CONFIG_DIR="$HOME/.config/nvim"
BACKUP_DIR="${CONFIG_DIR}.backup-$(date +%Y%m%d-%H%M%S)"

# Parse arguments
USE_HTTPS=false
if [[ "${1:-}" == "--https" ]]; then
    USE_HTTPS=true
fi

echo -e "${GREEN}Neovim Configuration Quick Setup${NC}"
echo "=================================="
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check for Neovim
if ! command -v nvim &> /dev/null; then
    echo -e "${RED}✗ Neovim not found!${NC}"
    echo "  Please install Neovim 0.10+ first:"
    echo "  - macOS: brew install neovim"
    echo "  - Ubuntu: sudo apt install neovim"
    echo "  - See: https://github.com/neovim/neovim/wiki/Installing-Neovim"
    exit 1
else
    NVIM_VERSION=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+')
    echo -e "${GREEN}✓ Neovim ${NVIM_VERSION} found${NC}"
fi

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git not found!${NC}"
    echo "  Please install git first"
    exit 1
else
    echo -e "${GREEN}✓ Git found${NC}"
fi

# Check for R (optional)
if command -v R &> /dev/null; then
    R_VERSION=$(R --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    echo -e "${GREEN}✓ R ${R_VERSION} found${NC}"
else
    echo -e "${YELLOW}⚠ R not found (optional but recommended for R development)${NC}"
fi

# Check for radian (optional)
if command -v radian &> /dev/null; then
    echo -e "${GREEN}✓ Radian found${NC}"
else
    echo -e "${YELLOW}⚠ Radian not found (optional but provides better R REPL)${NC}"
    echo "  Install with: pip install -U radian"
fi

echo ""

# Backup existing config
if [[ -e "$CONFIG_DIR" ]]; then
    echo -e "${YELLOW}Backing up existing config...${NC}"
    mv "$CONFIG_DIR" "$BACKUP_DIR"
    echo -e "${GREEN}✓ Backed up to: $BACKUP_DIR${NC}"
fi

# Clone repository
echo -e "${YELLOW}Cloning configuration...${NC}"
if [[ "$USE_HTTPS" == true ]]; then
    echo "Using HTTPS (you can switch to SSH later with: make set-remote USER=go-bayes)"
    git clone "$REPO_HTTPS" "$CONFIG_DIR"
else
    echo "Using SSH (use --https flag if you don't have SSH keys set up)"
    git clone "$REPO_SSH" "$CONFIG_DIR" || {
        echo -e "${RED}SSH clone failed. Trying HTTPS...${NC}"
        git clone "$REPO_HTTPS" "$CONFIG_DIR"
        echo -e "${YELLOW}Note: Cloned via HTTPS. Set up SSH later with: make setup-ssh${NC}"
    }
fi
echo -e "${GREEN}✓ Configuration cloned${NC}"

# Install plugins
echo ""
echo -e "${YELLOW}Installing Neovim plugins...${NC}"
echo "This may take a minute..."

# Try headless sync first
if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
    echo -e "${GREEN}✓ Plugins installed${NC}"
else
    echo -e "${YELLOW}Headless sync failed. Please run :Lazy sync manually in Neovim${NC}"
fi

# Install R packages if R is available
if command -v R &> /dev/null; then
    echo ""
    echo -e "${YELLOW}Checking R packages...${NC}"

    R_PACKAGES=("languageserver" "styler" "callr" "lintr")
    MISSING_PACKAGES=""

    for pkg in "${R_PACKAGES[@]}"; do
        if R --slave -e "if (!requireNamespace('$pkg', quietly = TRUE)) quit(status = 1)" 2>/dev/null; then
            echo -e "${GREEN}✓ R package '$pkg' found${NC}"
        else
            MISSING_PACKAGES="$MISSING_PACKAGES'$pkg',"
        fi
    done

    if [[ -n "$MISSING_PACKAGES" ]]; then
        MISSING_PACKAGES="${MISSING_PACKAGES%,}"  # Remove trailing comma
        echo -e "${YELLOW}Missing R packages. Install with:${NC}"
        echo "  R -e \"install.packages(c($MISSING_PACKAGES))\""
    fi
fi

# Check for recommended tools
echo ""
echo -e "${YELLOW}Checking optional tools...${NC}"

if command -v rg &> /dev/null; then
    echo -e "${GREEN}✓ ripgrep found${NC}"
else
    echo -e "${YELLOW}⚠ ripgrep not found (recommended for fast searching)${NC}"
    echo "  Install with: brew install ripgrep"
fi

if command -v fd &> /dev/null; then
    echo -e "${GREEN}✓ fd found${NC}"
else
    echo -e "${YELLOW}⚠ fd not found (recommended for fast file finding)${NC}"
    echo "  Install with: brew install fd"
fi

# Final instructions
echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Open Neovim: nvim"
echo "2. Check plugin status: :Lazy"
echo "3. Check health: :checkhealth"
echo "4. Try opening an R file and press <space>rs to start REPL"
echo ""
echo "If you backed up an existing config, it's saved at:"
echo "  $BACKUP_DIR"
echo ""
echo "To update your config later:"
echo "  cd ~/.config/nvim && git pull && make sync"
echo ""
echo "Happy coding!"