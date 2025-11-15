local M = {}

local started = {}

local function wants_python_repl(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.bo[bufnr].filetype == "python"
end

function M.ensure_running(opts)
  if not wants_python_repl() then
    return
  end

  local ok, iron = pcall(require, "iron.core")
  if not ok then
    return
  end

  local ft = "python"
  if opts and opts.force then
    started[ft] = nil
  end
  if started[ft] then
    return
  end

  local repl_ok, err = pcall(function()
    iron.repl_for(ft)
  end)

  if repl_ok then
    started[ft] = true
  else
    started[ft] = nil
    vim.schedule(function()
      vim.notify_once(
        "Failed to start Python REPL (" .. tostring(err) .. ")",
        vim.log.levels.WARN,
        { title = "Python REPL" }
      )
    end)
  end
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.py", "*.pyw" },
  callback = function()
    M.ensure_running()
  end,
  desc = "Auto-start Python REPL for Python buffers",
})

vim.api.nvim_create_user_command("PyEnsureRepl", function()
  M.ensure_running({ force = true })
end, { desc = "Restart the Python REPL if needed" })

return M
