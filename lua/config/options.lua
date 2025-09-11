-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- disable cursor line highlighting (fixes white line selection issue)
vim.opt.cursorline = false

-- configure for terminal capabilities
-- Apple Terminal doesn't support true colors, so disable termguicolors
if os.getenv("TERM_PROGRAM") == "Apple_Terminal" then
  vim.opt.termguicolors = false
else
  vim.opt.termguicolors = true
end

