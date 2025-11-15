-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.number = true

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
  vim.opt.guifont = "JetBrainsMono Nerd Font Light:h14"
end
