-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- soft-wrap for markdown and quarto files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "quarto", "rmd", "qmd" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.colorcolumn = ""
  end,
})

-- Fallback: enable soft-wrap by filename pattern in case filetype isn't set yet
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  pattern = { "*.md", "*.qmd", "*.Rmd", "*.rmd" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.colorcolumn = ""
  end,
})

-- Enter insert (terminal) mode automatically when a terminal opens (e.g., REPL)
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = { "term://*" },
  callback = function()
    vim.cmd("startinsert")
  end,
})

-- Conservative format-on-the-fly for R-related buffers using conform.nvim + styler
vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
  pattern = { "*.R", "*.r", "*.qmd", "*.Rmd", "*.rmd" },
  callback = function()
    local ok, conform = pcall(require, "conform")
    if not ok then return end
    -- Only run if filetype is R-like and buffer is modifiable
    local ft = vim.bo.filetype
    if ft == "r" or ft == "qmd" or ft == "rmd" or ft == "quarto" then
      conform.format({ async = true, lsp_fallback = false, timeout_ms = 2000 })
    end
  end,
})
