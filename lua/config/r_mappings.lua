-- R-specific mappings and Iron integration
local M = {}

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "rmd", "quarto", "qmd" },
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    -- Insert-mode helpers
    vim.keymap.set("i", "jj", " <- ", { buffer = bufnr, desc = "R assignment (jj)" })
    vim.keymap.set("i", "kk", " |> ", { buffer = bufnr, desc = "R pipe (kk)" })

    -- Ensure no stale send-line/selection mappings remain; let iron.nvim provide them
    pcall(vim.keymap.del, "n", "<space>sl", { buffer = bufnr })
    pcall(vim.keymap.del, "v", "<space>sc", { buffer = bufnr })
  end,
  desc = "R key mappings",
})

return M
