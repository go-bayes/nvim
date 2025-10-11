-- basic python-specific insert-mode helpers
local M = {}

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.keymap.set("i", "jl", "lambda : ", { buffer = bufnr, desc = "python lambda (jl)" })
    vim.keymap.set("i", "jd", "def ", { buffer = bufnr, desc = "python def (jd)" })
    vim.keymap.set("i", "ji", "import ", { buffer = bufnr, desc = "python import (ji)" })
  end,
  desc = "python key mappings",
})

return M
