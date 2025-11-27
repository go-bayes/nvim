-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local pins = require("config.pins")

-- system clipboard integration (explicit)
-- use these when regular yank doesn't copy to system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', '"+Y', { noremap = true, silent = true, desc = 'Yank line to system clipboard' })
-- System clipboard paste (after) on Shift+P
vim.keymap.set('n', 'P', '"+p', { noremap = true, silent = true, desc = 'Paste after from system clipboard (no extra space)' })
vim.keymap.set('v', 'P', '"_d"+p', { noremap = true, silent = true, desc = 'Paste after from system clipboard (keep clipboard)' })

-- System clipboard paste on <leader>p (copy then paste while staying in normal mode)
vim.keymap.set('n', '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste after from system clipboard' })
vim.keymap.set('v', '<leader>p', '"_d"+p', { noremap = true, silent = true, desc = 'Paste after from system clipboard (keep clipboard)' })

-- Keep optional leader+P as an alternate for system clipboard paste (after)
vim.keymap.set({ 'n', 'v' }, '<leader>P', '"+p', { noremap = true, silent = true, desc = 'Paste after from system clipboard' })

-- direct pbcopy integration (guaranteed to work)
vim.keymap.set('v', '<leader>cc', ':w !pbcopy<CR><CR>', { noremap = true, silent = true, desc = 'Copy to macOS clipboard (pbcopy)' })
vim.keymap.set('n', '<leader>cc', 'V:w !pbcopy<CR><CR>', { noremap = true, silent = true, desc = 'Copy line to macOS clipboard' })

-- Copy current file path to system clipboard
local function copy_file_path()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("Buffer has no file path", vim.log.levels.WARN, { title = "Copy path" })
    return
  end
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied file path" })
end
vim.keymap.set('n', '<leader>cf', copy_file_path, { noremap = true, silent = true, desc = 'Copy file path (abs) to clipboard' })

-- Paste current file path at cursor (avoids register confusion / E78)
local function paste_file_path()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("Buffer has no file path", vim.log.levels.WARN, { title = "Paste file path" })
    return
  end
  vim.api.nvim_put({ path }, "c", true, true)
end
vim.keymap.set('n', '<leader>pf', paste_file_path, { noremap = true, silent = true, desc = 'Paste file path at cursor' })

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
-- Create blank lines without leaving normal mode
vim.keymap.set('n', 'go', 'o<Esc>', { noremap = true, silent = true, desc = 'Blank line below (stay normal)' })
vim.keymap.set('n', 'gO', 'O<Esc>', { noremap = true, silent = true, desc = 'Blank line above (stay normal)' })

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
vim.keymap.set('n', 'A', 'g$a', { noremap = true, silent = true, desc = 'Append at end of wrapped line' })

vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true, nowait = true, desc = 'Exit terminal mode' })
vim.keymap.set('t', '<C-g>', [[<C-\><C-n>]], { noremap = true, silent = true, nowait = true, desc = 'Exit terminal mode (Ctrl-G)' })
-- Jump back to previous window (source) from anywhere
vim.keymap.set('n', '<leader>rp', '<C-w>p', { noremap = true, silent = true, desc = 'Previous window' })
vim.keymap.set('t', '<leader>rp', [[<C-\><C-n><C-w>p]], { noremap = true, silent = true, desc = 'Previous window' })


-- Quick wrappers for common R object introspection
local function wrap_word_with(format_string, opts)
  opts = opts or {}
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col0 = cursor[2]
  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
  if line == "" then
    return
  end

  local function is_allowed(char)
    return char:match("[%w_.$]") ~= nil
  end

  local col1 = col0 + 1
  local len = #line
  if col1 > len then col1 = len end
  if col1 < 1 then col1 = 1 end

  if not is_allowed(line:sub(col1, col1)) then
    if col1 > 1 and is_allowed(line:sub(col1 - 1, col1 - 1)) then
      col1 = col1 - 1
    elseif col1 < len and is_allowed(line:sub(col1 + 1, col1 + 1)) then
      col1 = col1 + 1
    else
      return
    end
  end

  local left = col1
  while left > 1 and is_allowed(line:sub(left - 1, left - 1)) do
    left = left - 1
  end

  local right = col1
  while right < len and is_allowed(line:sub(right + 1, right + 1)) do
    right = right + 1
  end

  local object = line:sub(left, right)
  if object == "" then
    return
  end
  local indent = line:match("^%s*") or ""

  local replacement = string.format(format_string, object)

  vim.api.nvim_buf_set_text(buf, row, left - 1, row, right, { replacement })

  if opts.append_original then
    vim.api.nvim_buf_set_lines(buf, row + 1, row + 1, false, { indent .. object })
  end

  vim.api.nvim_win_set_cursor(0, { cursor[1], left - 1 + #replacement })

  return object
end

vim.keymap.set('n', '<leader>cn', function()
  wrap_word_with('colnames(%s)')
end, { noremap = true, silent = true, desc = 'Wrap word with colnames()' })

vim.keymap.set('n', '<leader>nn', function()
  wrap_word_with('names(%s)')
end, { noremap = true, silent = true, desc = 'Wrap word with names()' })

vim.keymap.set('n', '<leader>ci1', function()
  wrap_word_with('str(%s, max.level = 1)', { append_original = true })
end, { noremap = true, silent = true, desc = 'Wrap word with str(..., max.level = 1)' })

vim.keymap.set('n', '<leader>ci2', function()
  wrap_word_with('str(%s, max.level = 2)', { append_original = true })
end, { noremap = true, silent = true, desc = 'Wrap word with str(..., max.level = 2)' })


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
vim.keymap.set('n', '<leader>hr', function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    vim.notify('Buffer has no name', vim.log.levels.WARN, { title = 'Pins' })
    return
  end

  for idx, item in ipairs(pins.list()) do
    if item and item.path == path then
      pins.remove(idx)
      return
    end
  end

  vim.notify('Current file is not pinned', vim.log.levels.WARN, { title = 'Pins' })
end, { noremap = true, silent = true, desc = 'Remove current file pin' })
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


-- Toggle diagnostics per-buffer
vim.keymap.set("n", "<leader>dd", function()
  vim.diagnostic.disable(0)
end, { noremap = true, silent = true, desc = "Disable diagnostics (buffer)" })

vim.keymap.set("n", "<leader>de", function()
  vim.diagnostic.enable(0)
end, { noremap = true, silent = true, desc = "Enable diagnostics (buffer)" })

-- silence diagnostics in otter virtual buffers
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.otter.R", "*.otter.*" },
  callback = function(args)
    vim.diagnostic.disable(args.buf)
  end,
})
