# Neovim Configuration for R & Quarto Development

Personal Neovim configuration optimised for R, Quarto, and statistical computing workflows.

## Features

### RStudio-Style Keybindings
- `Cmd + -` → Assignment operator (`<-`)
- `Cmd + Shift + A` → Align assignments
- `Cmd + Shift + R` → Section comments
- `Enter` / `Cmd + Enter` → Send code to R console

### Git Directory Navigation
- `<leader>gd` → Change to GIT directory
- `<leader>gt` → Find files in GIT directory
- `<leader>gg` → Search in GIT directory
- `<leader>gf` → Find R/Quarto/Python files in GIT
- `<leader>gr` → Find R/Quarto files only

### Project Shortcuts
- `<leader>gm` → Go to margot project
- `<leader>ge` → Go to epic-models project
- `<leader>gb` → Go to boilerplate project
- `<leader>gl` → Go to letters project
- `<leader>gp` → Go to templates project

### File Navigation & Search
- `<space>ff` → Find files
- `<space>fg` → Live grep
- `<space>fb` → Find buffers
- `<space>fr` → Recent files
- `<leader>e` → Toggle file tree

### Language Support
- **R**: R.nvim with console integration, autocompletion
- **Quarto**: Preview, export, syntax highlighting
- **Python**: Pyright LSP, autocompletion
- **LaTeX**: VimTeX, TexLab LSP
- **Others**: JSON, CSV, Markdown support

## Installation

1. Backup existing config: `mv ~/.config/nvim ~/.config/nvim.bak`
2. Clone this repo: `git clone git@github.com:go-bayes/nvim.git ~/.config/nvim`
3. Start Neovim: `nvim`
4. Plugins will install automatically via Lazy

## Dependencies

- R with required packages
- Python 3 (with venv at `~/.venvs/nvim/`)
- `make` (for telescope-fzf-native)
- LaTeX distribution (for LaTeX support)
- Quarto CLI (for Quarto support)

## Customisation

Leader key is `<space>`. Modify `init.lua` to adjust keybindings and plugin configurations.