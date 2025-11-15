#!/bin/bash
# setup script for python packages required by neovim
# uses pipx for CLI tools and pip for libraries

set -e  # exit on error

# colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # no colour

echo -e "${GREEN}neovim python setup${NC}"
echo "================================"
echo
echo "strategy:"
echo "  • pipx for CLI tools (ipython, pyright, ruff)"
echo "  • pip --user for libraries (pynvim)"
echo "  • pipx ensurepath to ensure neovim can find executables"
echo

# check if python3 is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}error: python3 not found${NC}"
    echo "please install python3 first"
    exit 1
fi

# get python version
PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}found python:${NC} $PYTHON_VERSION"

# check for pipx
if ! command -v pipx &> /dev/null; then
    echo -e "${RED}error: pipx not found${NC}"
    echo "please install pipx first:"
    echo "  brew install pipx"
    exit 1
fi

PIPX_VERSION=$(pipx --version)
echo -e "${GREEN}found pipx:${NC} $PIPX_VERSION"
echo

PYTHON_BIN=$(command -v python3)
if [ -z "$PYTHON_BIN" ]; then
    echo -e "${RED}error: unable to resolve python3 path${NC}"
    exit 1
fi

# ensure pipx path is set up
echo -e "${BLUE}1. ensuring pipx path...${NC}"
pipx ensurepath --quiet 2>/dev/null || true
echo "   ✓ pipx path configured"
echo

# upgrade pip first
echo -e "${BLUE}2. upgrading pip...${NC}"
python3 -m pip install --upgrade pip --user --quiet --break-system-packages 2>/dev/null || python3 -m pip install --upgrade pip --user --quiet
echo "   ✓ pip upgraded"
echo

# install CLI tools with pipx
echo -e "${BLUE}3. installing CLI tools with pipx...${NC}"

echo "   installing ipython..."
pipx install ipython --python "$PYTHON_BIN" --force --quiet 2>/dev/null || pipx upgrade ipython --quiet 2>/dev/null
echo "   ✓ ipython installed"

echo "   installing pyright..."
pipx install pyright --python "$PYTHON_BIN" --force --quiet 2>/dev/null || pipx upgrade pyright --quiet 2>/dev/null
echo "   ✓ pyright installed"

echo "   installing ruff..."
pipx install ruff --python "$PYTHON_BIN" --force --quiet 2>/dev/null || pipx upgrade ruff --quiet 2>/dev/null
echo "   ✓ ruff installed"

echo "   installing uv..."
pipx install uv --python "$PYTHON_BIN" --force --quiet 2>/dev/null || pipx upgrade uv --quiet 2>/dev/null
echo "   ✓ uv installed"
echo

# install libraries with pip
echo -e "${BLUE}4. installing libraries with pip...${NC}"

echo "   installing pynvim (user packages)..."
python3 -m pip install --upgrade --user pynvim --quiet --break-system-packages
echo "   ✓ pynvim installed"
echo

# verify installation
echo -e "${BLUE}5. verifying installation...${NC}"

echo -e "   ${YELLOW}pynvim:${NC}"
python3 -c "import pynvim; print(f'     ✓ version {pynvim.__version__}')" 2>/dev/null || echo -e "${RED}     ✗ not found${NC}"

echo -e "   ${YELLOW}ipython:${NC}"
if command -v ipython &> /dev/null; then
    IPYTHON_VERSION=$(ipython --version)
    echo "     ✓ version $IPYTHON_VERSION"
else
    echo -e "${RED}     ✗ not found${NC}"
fi

echo -e "   ${YELLOW}pyright:${NC}"
if command -v pyright &> /dev/null; then
  PYRIGHT_VERSION=$(pyright --version 2>&1 | head -1)
  echo "     ✓ $PYRIGHT_VERSION"
else
  echo -e "${RED}     ✗ not found${NC}"
fi

echo -e "   ${YELLOW}ruff:${NC}"
if command -v ruff &> /dev/null; then
  RUFF_VERSION=$(ruff --version 2>&1 | head -1)
  echo "     ✓ $RUFF_VERSION"
else
  echo -e "${RED}     ✗ not found${NC}"
fi

echo -e "   ${YELLOW}uv:${NC}"
if command -v uv &> /dev/null; then
  UV_VERSION=$(uv --version 2>&1 | head -1)
  echo "     ✓ $UV_VERSION"
else
  echo -e "${RED}     ✗ not found${NC}"
fi

echo
echo -e "${GREEN}setup complete!${NC}"
echo
echo "neovim python features:"
echo "  • insert-mode shortcuts: jl (lambda), jd (def), ji (import)"
echo "  • LSP: pyright for autocomplete and diagnostics"
echo "  • formatting: ruff (format on save enabled)"
echo "  • REPL: ipython via iron.nvim (prefers project-local .venv ipython)"
echo "  • per-project envs: use 'uv venv .venv' inside python projects"
echo
echo "restart neovim to use the updated python environment"
