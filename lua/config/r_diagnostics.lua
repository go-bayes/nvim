local M = {}

local default_config = {
  virtual_text = {
    spacing = 2,
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
}

vim.diagnostic.config(default_config)

local function diagnostics_disabled(bufnr)
  if vim.diagnostic.is_enabled then
    return not vim.diagnostic.is_enabled({ bufnr = bufnr })
  end
  if vim.diagnostic.is_disabled then
    return vim.diagnostic.is_disabled(nil, bufnr)
  end
  return false
end

function M.on_attach(_, bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, "RDiagnosticsToggle", function()
    if diagnostics_disabled(bufnr) then
      vim.diagnostic.enable(nil, bufnr)
      vim.notify("R diagnostics enabled", vim.log.levels.INFO)
    else
      vim.diagnostic.disable(nil, bufnr)
      vim.notify("R diagnostics disabled", vim.log.levels.INFO)
    end
  end, { desc = "Toggle diagnostics for this buffer" })
end

return M
