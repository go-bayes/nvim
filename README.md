# Neovim Config

LazyVim-based setup tuned for R and Quarto work, run inside Kitty.

## Install

Clone into `~/.config/nvim`, start Neovim, and run `:Lazy sync` once to fetch the pinned plugins.

## Dotfiles backup

The repo also tracks non-Neovim config that pairs with this setup. To install the AeroSpace keybinding config on a new machine, run:

```bash
./scripts/link-dotfiles.sh
```

That will symlink `dotfiles/aerospace/.aerospace.toml` into `~/.aerospace.toml`. Reload AeroSpace (`aerospace reload-config`) to apply the shortcuts.
