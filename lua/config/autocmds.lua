pcall(require, "config.r_repl")

-- Ensure autoformat stays enabled in R-related buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "rmd", "qmd", "quarto" },
  callback = function()
    vim.b.autoformat = true
  end,
})

-- Show raw fenced code (no conceal) in Quarto/Markdown buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "quarto", "markdown", "rmd", "qmd" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Force conform.nvim formatting on save for R-related buffers
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.R", "*.r", "*.qmd", "*.Rmd", "*.rmd" },
  callback = function(event)
    local ok, conform = pcall(require, "conform")
    if not ok then return end
    conform.format({ bufnr = event.buf, async = false, lsp_fallback = false })
  end,
})

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

-- Trigger completion immediately after typing `$` in R buffers (helps data frame column hints)
vim.api.nvim_create_autocmd("TextChangedI", {
  pattern = { "*.R", "*.r", "*.qmd", "*.Rmd", "*.rmd" },
  callback = function()
    local ok, blink = pcall(require, "blink.cmp")
    if not ok or not blink or blink.is_visible() then return end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local col = cursor[2]
    if col <= 0 then return end

    local line = vim.api.nvim_get_current_line()
    if col > #line then return end
    local char = line:sub(col, col)
    if char == "$" then blink.show() end
  end,
})
