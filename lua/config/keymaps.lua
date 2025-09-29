-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local pins = require("config.pins")

-- system clipboard integration (explicit)
-- use these when regular yank doesn't copy to system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', '"+Y', { noremap = true, silent = true, desc = 'Yank line to system clipboard' })
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from system clipboard' })
vim.keymap.set({'n', 'v'}, '<leader>P', '"+P', { noremap = true, silent = true, desc = 'Paste before from system clipboard' })

-- direct pbcopy integration (guaranteed to work)
vim.keymap.set('v', '<leader>cc', ':w !pbcopy<CR><CR>', { noremap = true, silent = true, desc = 'Copy to macOS clipboard (pbcopy)' })
vim.keymap.set('n', '<leader>cc', 'V:w !pbcopy<CR><CR>', { noremap = true, silent = true, desc = 'Copy line to macOS clipboard' })

-- Quick escape from insert mode
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true, desc = 'Exit insert mode' })

-- Clear search highlights while preserving default <Esc>
vim.keymap.set('n', '<Esc>', function()
  if vim.v.hlsearch == 1 then vim.cmd('nohlsearch') end
  return '<Esc>'
end, { noremap = true, silent = true, expr = true, desc = 'Clear search highlight' })

-- Yank/paste tweaks
vim.keymap.set('n', 'Y', 'y$', { noremap = true, silent = true, desc = 'Yank to end of line' })
vim.keymap.set('v', 'p', '"_dP', { noremap = true, silent = true, desc = 'Paste without overwriting register' })

-- macOS-style clipboard shortcuts (require clipboard=unnamedplus)
vim.keymap.set({ 'n', 'v' }, '<D-c>', '"+y', { noremap = true, silent = true, desc = 'Copy to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<D-x>', '"+d', { noremap = true, silent = true, desc = 'Cut to system clipboard' })
vim.keymap.set('n', '<D-v>', '"+p', { noremap = true, silent = true, desc = 'Paste from system clipboard' })
vim.keymap.set('v', '<D-v>', '"+P', { noremap = true, silent = true, desc = 'Paste from system clipboard' })
vim.keymap.set('i', '<D-v>', function()
  return vim.api.nvim_replace_termcodes('<C-r>+', true, true, true)
end, { noremap = true, silent = true, expr = true, desc = 'Paste clipboard' })

-- Save shortcuts
vim.keymap.set({ 'n', 'i' }, '<C-s>', function()
  local mode = vim.fn.mode():sub(1, 1)
  if mode == 'i' then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
  end
  vim.cmd('write')
  if mode == 'i' then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('a', true, false, true), 'n', true)
  end
end, { noremap = true, silent = true, desc = 'Save file' })

-- Leader-based window and buffer helpers
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { noremap = true, silent = true, desc = 'Write buffer' })
vim.keymap.set('n', '<leader>qq', '<cmd>q<CR>', { noremap = true, silent = true, desc = 'Quit window' })
vim.keymap.set('n', '<leader>e', '<cmd>Lex 30<CR>', { noremap = true, silent = true, desc = 'Open file explorer' })

-- Movement over wrapped lines (behave like screen lines)
vim.keymap.set({ 'n', 'v' }, 'j', 'gj', { noremap = true, silent = true, desc = 'Down (wrapped)' })
vim.keymap.set({ 'n', 'v' }, 'k', 'gk', { noremap = true, silent = true, desc = 'Up (wrapped)' })
vim.keymap.set({ 'n', 'v' }, '$', 'g$', { noremap = true, silent = true, desc = 'End of wrapped line' })
vim.keymap.set({ 'n', 'v' }, '0', 'g0', { noremap = true, silent = true, desc = 'Start of wrapped line' })

-- Convenience: exit terminal mode with ESC
vim.keymap.set('t', '<Esc>', [[<C-"><C-n>]], { noremap = true, silent = true, desc = 'Exit terminal mode' })
-- Jump back to previous window (source) from anywhere
vim.keymap.set('n', '<leader>rp', '<C-w>p', { noremap = true, silent = true, desc = 'Previous window' })
vim.keymap.set('t', '<leader>rp', [[<C-\\><C-n><C-w>p]], { noremap = true, silent = true, desc = 'Previous window' })


-- Quick wrappers for common R object introspection
local wrap_word_with = function(expr)
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  local keys = 'yiwciw' .. expr .. esc
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', false)
end

vim.keymap.set('n', '<leader>cn', function()
  wrap_word_with('colnames(<C-r>0)')
end, { noremap = true, silent = true, desc = 'Wrap word with colnames()' })

vim.keymap.set('n', '<leader>nn', function()
  wrap_word_with('names(<C-r>0)')
end, { noremap = true, silent = true, desc = 'Wrap word with names()' })


-- Alias keybindings for iron.nvim to match VS Code (ssp for send paragraph)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "rmd", "quarto", "qmd" },
  callback = function()
    -- Create aliases that trigger Iron's lazy loading and then execute the command
    vim.keymap.set('n', '<leader>ssl', '<leader>sl', { remap = true, desc = 'Send line (ssl alias)' })
    vim.keymap.set({'n', 'v'}, '<leader>ssc', '<leader>sc', { remap = true, desc = 'Send selection (ssc alias)' })
    vim.keymap.set('n', '<leader>ssp', '<leader>sp', { remap = true, desc = 'Send paragraph (ssp alias)' })
  end,
})

-- Toggle maximize for the current window and restore layout on repeat
vim.keymap.set('n', '<leader>wm', function()
  local current_win = vim.api.nvim_get_current_win()
  local restore = vim.t._max_restore

  if restore and vim.api.nvim_win_is_valid(restore.win) and restore.win == current_win then
    vim.cmd(restore.cmd)
    vim.t._max_restore = nil
    return
  end

  vim.t._max_restore = { win = current_win, cmd = vim.fn.winrestcmd() }
  vim.cmd('wincmd |')
  vim.cmd('wincmd _')
end, { noremap = true, silent = true, desc = 'Toggle maximize current window' })


-- Quick toggle between current and previous window
vim.keymap.set('n', '<leader>ww', '<C-w>p', { noremap = true, silent = true, desc = 'Focus previous window' })
vim.keymap.set('t', '<leader>ww', [[<C-\><C-n><C-w>p]], { noremap = true, silent = true, desc = 'Focus previous window' })


-- Simple pinned file navigation (Harpoon alternative)
vim.keymap.set('n', '<leader>ha', pins.add, { noremap = true, silent = true, desc = 'Pin current file' })
vim.keymap.set('n', '<leader>hh', pins.menu, { noremap = true, silent = true, desc = 'Show pinned files' })
vim.keymap.set('n', '<leader>h1', function()
  pins.select(1)
end, { noremap = true, silent = true, desc = 'Go to pin 1' })
vim.keymap.set('n', '<leader>h2', function()
  pins.select(2)
end, { noremap = true, silent = true, desc = 'Go to pin 2' })
vim.keymap.set('n', '<leader>h3', function()
  pins.select(3)
end, { noremap = true, silent = true, desc = 'Go to pin 3' })
vim.keymap.set('n', '<leader>h4', function()
  pins.select(4)
end, { noremap = true, silent = true, desc = 'Go to pin 4' })
