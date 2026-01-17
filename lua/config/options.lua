-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.number = true

-- keep a bottom margin without enforcing top scrolloff
vim.opt.scrolloff = 0
local bottom_margin = 10

local function keep_bottom_margin()
  local win = vim.api.nvim_get_current_win()
  local height = vim.api.nvim_win_get_height(win)
  local cursor = vim.api.nvim_win_get_cursor(win)[1]
  local topline = vim.fn.line("w0")
  local max_cursor = topline + height - 1 - bottom_margin

  if cursor > max_cursor then
    local new_top = cursor - (height - bottom_margin - 1)
    if new_top < 1 then
      new_top = 1
    end
    vim.fn.winrestview({ topline = new_top })
  end
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinScrolled", "BufEnter" }, {
  callback = keep_bottom_margin,
})

-- disable swap files
vim.opt.swapfile = false

-- enable system clipboard integration (allows pasting outside nvim)
vim.opt.clipboard = "unnamedplus"

-- ensure clipboard works on macOS
if vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 then
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 0,
  }
end

-- disable cursor line highlighting (fixes white line selection issue)
vim.opt.cursorline = false

-- configure for terminal capabilities
-- Apple Terminal doesn't support true colors, so disable termguicolors
if os.getenv("TERM_PROGRAM") == "Apple_Terminal" then
  vim.opt.termguicolors = false
else
  vim.opt.termguicolors = true
end

if vim.fn.exists("&guifont") == 1 then
  vim.opt.guifont = "JetBrainsMono Nerd Font:h19"
end
