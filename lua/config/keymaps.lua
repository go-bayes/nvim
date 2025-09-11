-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 0 for line boundaries with display lines
vim.keymap.set({'n', 'v'}, '0', 'g0', { noremap = true, silent = true })
