-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 0 for line boundaries with display lines
vim.keymap.set({'n', 'v'}, '0', 'g0', { noremap = true, silent = true })

-- Convenience: exit terminal mode with ESC
vim.keymap.set('t', '<Esc>', [[<C-"><C-n>]], { noremap = true, silent = true, desc = 'Exit terminal mode' })
-- Jump back to previous window (source) from anywhere
vim.keymap.set('n', '<leader>rp', '<C-w>p', { noremap = true, silent = true, desc = 'Previous window' })
vim.keymap.set('t', '<leader>rp', [[<C-\\><C-n><C-w>p]], { noremap = true, silent = true, desc = 'Previous window' })
