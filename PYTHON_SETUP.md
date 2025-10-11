# python setup for neovim

This document describes the standardised python environment setup for neovim.

## overview

The neovim configuration requires specific python packages to enable:
- Python language server integration (pyright)
- Interactive REPL via iron.nvim (ipython)
- Python provider for neovim (pynvim)
- Code formatting and linting tools

## requirements

- Python 3.10 or later (currently using Python 3.14.0 from Homebrew)
- pip package manager

## installation protocol

### quick setup

Run the automated setup script:

```bash
~/.config/nvim/scripts/setup_python.sh
```

This script will:
1. Verify python3 is available
2. Upgrade pip to the latest version
3. Install all required packages from `python-requirements.txt`
4. Verify the installation

### manual setup

If you prefer manual installation:

```bash
python3 -m pip install -r ~/.config/nvim/python-requirements.txt
```

## required packages

The following packages are installed via `python-requirements.txt`:

### core neovim integration
- **pynvim**: Python provider for neovim (required)
- **pyright**: Type checker for LSP integration

### REPL and development
- **ipython**: Enhanced interactive python shell (used by iron.nvim)
- **ipdb**: IPython-enabled debugger
- **jupyter**: Jupyter notebook support

### code quality tools
- **black**: Code formatter
- **ruff**: Fast python linter

## verification

After installation, verify the setup:

```bash
# check pynvim
python3 -c "import pynvim; print(pynvim.__version__)"

# check ipython
ipython --version

# check in neovim
nvim --headless -c 'echo exepath("python3")' -c 'quit'
```

## iron.nvim REPL configuration

The neovim configuration (in `lua/plugins/iron-r.lua`) automatically detects and uses ipython:

- If `ipython` is available: uses `ipython --no-autoindent`
- Otherwise: falls back to `python3`

## python version management

The setup uses the system python3 from Homebrew:
- Location: `/opt/homebrew/bin/python3`
- Currently: Python 3.14.0

To switch python versions:
1. Install desired version via Homebrew: `brew install python@3.x`
2. Update symlink: `brew link python@3.x`
3. Re-run setup script: `~/.config/nvim/scripts/setup_python.sh`

## troubleshooting

### neovim not finding python

Check what python neovim sees:
```bash
nvim --headless -c 'echo exepath("python3")' -c 'quit'
```

### packages not found

Ensure packages are installed for the correct python:
```bash
python3 -m pip list | grep -E "(pynvim|ipython)"
```

### REPL not working

1. Verify ipython is installed: `which ipython`
2. Check iron.nvim status in neovim: `:IronRepl`
3. Check for errors: `:messages`

## updating packages

To update all python packages:

```bash
python3 -m pip install --upgrade -r ~/.config/nvim/python-requirements.txt
```

## comparison with R setup

This python setup mirrors the R environment approach:
- **R**: Uses `radian` REPL (falls back to base R)
- **Python**: Uses `ipython` REPL (falls back to base python3)
- Both use iron.nvim for REPL integration
- Both use LSP for code intelligence (r-languageserver / pyright)
- Both support code sending with the same keybindings

## keybindings

When editing python files, iron.nvim provides:

- `<space>rs`: Start/toggle REPL
- `<space>rb`: Open REPL in bottom split
- `<space>rv`: Open REPL in right split
- `<space>rr`: Restart REPL
- `<space>sl`: Send current line
- `<space>sc`: Send selection (visual mode)
- `<space>sf`: Send entire file
- `<space>sp`: Send paragraph
- `<space>s<space>`: Interrupt running code

See `lua/plugins/iron-r.lua` for complete keybinding list.
