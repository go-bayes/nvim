#!/bin/bash
# Modernised Neovim Python setup using uv (2025)
# Optimized for macOS (ARM64) and high-performance causal inference.

set -e  # Exit immediately if a command fails.

# Define colours for clear diagnostic feedback.
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Neovim Python Tooling Setup (uv-native)${NC}"
echo "==========================================="
echo

# Dependencies
if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED}error: python3 not found${NC}"
    echo "install with: brew install python"
    exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
    echo -e "${RED}error: uv not found${NC}"
    echo "install with: brew install uv"
    exit 1
fi

PYTHON_BIN="$(command -v python3)"

echo -e "${GREEN}found python:${NC} $(python3 --version)"
echo -e "${GREEN}found uv:${NC} $(uv --version)"
echo

# Ensure uv tool shims are reachable
if ! printf '%s' "$PATH" | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
    export PATH="$HOME/.local/bin:$PATH"
    echo -e "${YELLOW}note:${NC} added ~/.local/bin to PATH for this run"
    echo "      add it in your shell config to make it permanent"
    echo
fi

# 1. Provision CLI tools globally via uv tool.
echo -e "${BLUE}1. Installing/Updating global CLI tools...${NC}"

# Force re-installation to ensure alignment with the active uv configuration.
uv tool install pyright --force --quiet
uv tool install ruff --force --quiet
uv tool install ipython --force --quiet

echo "   ✓ pyright (LSP), ruff (Linter), and ipython (REPL) updated."
echo

# 2. Handle the Neovim Python bridge (pynvim).
# This uses the system python3 to provide the host for plugins.
echo -e "${BLUE}2. Updating pynvim bridge for Neovim...${NC}"
uv pip install --python "$PYTHON_BIN" --user --upgrade --break-system-packages pynvim 2>/dev/null || \
    uv pip install --python "$PYTHON_BIN" --user --upgrade pynvim

echo "   ✓ pynvim host updated using $(python3 --version)."
echo

# 3. Verification of paths and versions.
echo -e "${BLUE}3. Finalising verification...${NC}"

echo -e "   ${YELLOW}uv path:${NC}      $(command -v uv)"
echo -e "   ${YELLOW}python:${NC}       $(python3 --version)"

if command -v pyright >/dev/null 2>&1; then
    echo -e "   ${YELLOW}pyright:${NC}      $(pyright --version | head -n 1)"
else
    echo -e "   ${YELLOW}pyright:${NC}      not found"
fi

if command -v ruff >/dev/null 2>&1; then
    echo -e "   ${YELLOW}ruff version:${NC} $(ruff --version)"
else
    echo -e "   ${YELLOW}ruff version:${NC} not found"
fi

if command -v ipython >/dev/null 2>&1; then
    echo -e "   ${YELLOW}ipython:${NC}      $(ipython --version)"
else
    echo -e "   ${YELLOW}ipython:${NC}      not found"
fi

 "$PYTHON_BIN" -c "import pynvim; print('   pynvim:        ' + pynvim.__version__)" 2>/dev/null || \
    echo "   pynvim:        not found"

echo
echo -e "${GREEN}Setup complete!${NC}"
echo "Restart Neovim to ensure the updated provider is active."
