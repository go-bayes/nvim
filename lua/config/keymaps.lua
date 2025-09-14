-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- system clipboard integration (explicit)
-- use these when regular yank doesn't copy to system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', '"+Y', { noremap = true, silent = true, desc = 'Yank line to system clipboard' })
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from system clipboard' })
vim.keymap.set({'n', 'v'}, '<leader>P', '"+P', { noremap = true, silent = true, desc = 'Paste before from system clipboard' })

-- direct pbcopy integration (guaranteed to work)
vim.keymap.set('v', '<leader>cc', ':w !pbcopy<CR><CR>', { noremap = true, silent = true, desc = 'Copy to macOS clipboard (pbcopy)' })
vim.keymap.set('n', '<leader>cc', 'V:w !pbcopy<CR><CR>', { noremap = true, silent = true, desc = 'Copy line to macOS clipboard' })

-- 0 for line boundaries with display lines
vim.keymap.set({'n', 'v'}, '0', 'g0', { noremap = true, silent = true })

-- Convenience: exit terminal mode with ESC
vim.keymap.set('t', '<Esc>', [[<C-"><C-n>]], { noremap = true, silent = true, desc = 'Exit terminal mode' })
-- Jump back to previous window (source) from anywhere
vim.keymap.set('n', '<leader>rp', '<C-w>p', { noremap = true, silent = true, desc = 'Previous window' })
vim.keymap.set('t', '<leader>rp', [[<C-\\><C-n><C-w>p]], { noremap = true, silent = true, desc = 'Previous window' })
