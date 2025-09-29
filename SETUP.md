# Setup Guide for New Machines

This guide helps you set up this Neovim configuration on a new machine from the GitHub repository.

## Prerequisites

### 1. System Requirements
- **Neovim** 0.10+ ([Installation guide](https://github.com/neovim/neovim/wiki/Installing-Neovim))
- **Git** (for cloning the repository)
- **Make** (usually pre-installed on Unix systems)
- **Node.js** 18+ (for some LSP servers and plugins)

### 2. Terminal
- **Kitty** (recommended) or any modern terminal emulator
- Font: **JetBrainsMono Nerd Font** ([Download](https://www.nerdfonts.com/font-downloads))

### 3. R Environment
Required R packages (install after setting up Neovim):
```r
install.packages(c("languageserver", "styler", "callr", "lintr"))
```

### 4. Optional but Recommended
- **radian** - Enhanced R REPL (install via pip: `pip install -U radian`)
- **ripgrep** (`rg`) - Fast search tool (install via homebrew: `brew install ripgrep`)
- **fd** - Fast file finder (install via homebrew: `brew install fd`)

## Installation Methods

### Method 1: Using the Makefile (Recommended)

1. **Clone and set up in one command:**
```bash
# First, ensure the target directory doesn't exist or move it aside
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true

# Clone the repository
git clone git@github.com:go-bayes/nvim.git /tmp/nvim-temp

# Run bootstrap from the cloned repo
cd /tmp/nvim-temp
make bootstrap REPO=git@github.com:go-bayes/nvim.git TARGET=~/.config/nvim

# Clean up temp directory
rm -rf /tmp/nvim-temp
```

2. **Install plugins:**
```bash
cd ~/.config/nvim
make sync
```

Or manually in Neovim:
```vim
:Lazy sync
```

### Method 2: Direct Clone

1. **Backup existing config (if any):**
```bash
mv ~/.config/nvim ~/.config/nvim.backup-$(date +%Y%m%d)
```

2. **Clone the repository:**
```bash
git clone git@github.com:go-bayes/nvim.git ~/.config/nvim
```

3. **Open Neovim and sync plugins:**
```bash
nvim
# Inside Neovim, run:
:Lazy sync
# Then restart Neovim
```

### Method 3: Using HTTPS (if SSH isn't set up)

1. **Clone via HTTPS:**
```bash
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true
git clone https://github.com/go-bayes/nvim.git ~/.config/nvim
```

2. **Later, switch to SSH (optional):**
```bash
cd ~/.config/nvim
make set-remote USER=go-bayes
```

## Post-Installation Setup

### 1. Install R packages
Open R and run:
```r
# Essential packages
install.packages(c("languageserver", "styler", "callr", "lintr"))

# Additional recommended packages for data science
install.packages(c("tidyverse", "data.table", "rmarkdown", "quarto"))
```

### 2. Install Radian (optional but recommended)
```bash
# Using pip
pip install -U radian

# Or using pipx (recommended for isolated installation)
pipx install radian
```

### 3. Configure Kitty Terminal (if using)
Add to `~/.config/kitty/kitty.conf`:
```conf
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        14.0

# macOS specific - allow Alt key to work
macos_option_as_alt yes
```

### 4. Install Additional Tools

**On macOS (using Homebrew):**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install neovim ripgrep fd node
```

**On Ubuntu/Debian:**
```bash
# Add Neovim PPA for latest version
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim ripgrep fd-find nodejs npm
```

**On Arch Linux:**
```bash
sudo pacman -S neovim ripgrep fd nodejs npm
```

## Verification

After installation, verify everything is working:

1. **Check Neovim version:**
```bash
nvim --version  # Should be 0.10+
```

2. **Check plugin installation:**
```bash
nvim
:Lazy
# Should show all plugins as installed
```

3. **Test R integration:**
- Open an R file: `nvim test.R`
- Start REPL: `<space>rs`
- Send a line: Type `1 + 1` and press `<space>sl`

4. **Check health:**
```vim
:checkhealth
```

## Troubleshooting

### SSH Key Issues
If you can't clone via SSH:
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard (macOS)
pbcopy < ~/.ssh/id_ed25519.pub

# Add the key to GitHub Settings > SSH and GPG keys
```

Or use the Makefile helper:
```bash
cd ~/.config/nvim
make setup-ssh EMAIL=your-email@example.com
```

### Plugin Issues
- If plugins fail to install: `:Lazy restore` (uses the locked versions)
- Clear plugin cache: `rm -rf ~/.local/share/nvim/lazy`
- Check logs: `:Lazy log`

### R LSP Issues
If R language server doesn't start:
```r
# In R, reinstall
remove.packages("languageserver")
install.packages("languageserver")

# Test it works
languageserver::run()  # Should start without errors, Ctrl+C to stop
```

### Permissions Issues
```bash
# Ensure correct permissions
chmod -R u+rwX ~/.config/nvim
chmod -R u+rwX ~/.local/share/nvim
chmod -R u+rwX ~/.local/state/nvim
```

## Keeping in Sync

### Pull Latest Changes
```bash
cd ~/.config/nvim
git pull origin main
make sync  # Or :Lazy sync in Neovim
```

### Push Your Changes
```bash
cd ~/.config/nvim
make push M="your commit message"
```

## Uninstall

To completely remove this configuration:
```bash
# Remove config
rm -rf ~/.config/nvim

# Remove Neovim data
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Restore backup if you made one
mv ~/.config/nvim.backup ~/.config/nvim 2>/dev/null || true
```

## Additional Notes

- The configuration uses LazyVim as a base but is customised for R and Quarto workflows
- Iron.nvim is configured to prefer Radian over base R when available
- Diagnostics from R's language server are disabled by default to avoid lintr/callr issues
- The leader key is `<space>` and local leader is `\`

## Getting Help

- Check the README.md for key mappings and features
- Run `:help` in Neovim for built-in documentation
- Check `:Lazy` for plugin management
- Use `:checkhealth` to diagnose issues