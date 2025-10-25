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
    local root = vim.fn.getcwd()
    if root and root ~= "" then
      local job = vim.b.terminal_job_id
      if job then
        vim.api.nvim_chan_send(job, "cd " .. vim.fn.shellescape(root) .. "\n")
      end
    end
    vim.cmd("startinsert")
  end,
})

-- Mirror unnamed register to system clipboard so plain yanks work everywhere
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator ~= 'y' or vim.v.event.regname ~= '' then return end
    local text = vim.fn.getreg('"')
    local regtype = vim.fn.getregtype('"')
    vim.fn.setreg('+', text, regtype)
    vim.fn.setreg('*', text, regtype)
  end,
})

-- note: $ trigger for r is now handled in blink-complete.lua plugin to avoid conflicts
