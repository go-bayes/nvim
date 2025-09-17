local M = {}

local started = {}

local function target_ft()
  local ft = vim.bo.filetype
  if ft == "qmd" or ft == "quarto" or ft == "markdown" or ft == "rmd" then
    return "r"
  end
  return ft
end

function M.ensure_running(opts)
  local ok, iron = pcall(require, "iron.core")
  if not ok then return end
  local ft = target_ft()
  if ft ~= "r" then return end
  if opts and opts.force then started[ft] = nil end
  if started[ft] then return end
  started[ft] = true
  iron.repl_for(ft)
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.R", "*.r", "*.qmd", "*.Rmd", "*.rmd" },
  callback = function()
    M.ensure_running()
  end,
  desc = "Auto-start R REPL for R/Quarto buffers",
})

vim.api.nvim_create_user_command("REnsureRepl", function()
  M.ensure_running({ force = true })
end, { desc = "Restart the R REPL if needed" })

return M
