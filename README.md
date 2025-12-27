# Neovim Config

LazyVim-based setup tuned for R and Quarto work, run inside Kitty. This repo owns the Neovim bits; broader dotfiles live in the separate `yadm` repo.

## Install

Clone into `~/.config/nvim`, start Neovim, and run `:Lazy sync` once to fetch the pinned plugins.

## Themes

- Catppuccin (mocha) loads on startup. Reapply it any time with `<leader>uc` or `:CatppuccinTheme [flavour]`.
- Nord stays available on `<leader>un` / `:NordTheme`.
- TokyoNight cycles with `<leader>ut`; toggle transparency with `<leader>uT`.

All theme tooling belongs to this Neovim repo—manage it with `git` inside `~/.config/nvim` rather than `yadm`.

## Dotfiles

Broader dotfiles—including AeroSpace at `~/.aerospace.toml`—live in the separate `yadm` repo rather than here.
