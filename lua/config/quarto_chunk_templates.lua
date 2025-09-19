local M = {}

local function prompt(label, default)
  local result = vim.fn.input(label, default or "")
  if result == nil or result == "" then
    return default or ""
  end
  return result
end

local function escape_quotes(str)
  return str:gsub('"', '\\"')
end

local function insert_template(opts)
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]

  local to_insert = {}
  local pre_lines = 0
  if row > 0 then
    local prev = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
    if prev and not prev:match("^%s*$") then
      table.insert(to_insert, "")
      pre_lines = 1
    end
  end

  vim.list_extend(to_insert, opts.lines)
  local template_len = #opts.lines

  if opts.ensure_blank_after then
    table.insert(to_insert, "")
  end

  vim.api.nvim_buf_set_lines(buf, row, row, false, to_insert)

  local cursor_line = opts.cursor_line or template_len
  local target_line = row + pre_lines + cursor_line - 1
  local target_col = opts.cursor_col or 0
  vim.api.nvim_win_set_cursor(0, { target_line, target_col })
  if opts.enter_insert then
    vim.cmd("startinsert")
  end
end

function M.insert_figure_chunk()
  local label = prompt("Figure label: ", "fig-")
  local caption = escape_quotes(prompt("Figure caption: ", ""))
  local code = prompt("Figure code: ", "graph")

  local lines = {
    "```{r}",
    "#| label: " .. label,
    "#| fig-cap: \"" .. caption .. "\"",
    "#| eval: true",
    "#| echo: false",
    "#| fig-height: 12   # tweak if needed",
    "#| fig-width: 12    # tweak if needed",
    "",
    code,
    "```",
  }

  insert_template({ lines = lines, cursor_line = #lines - 1, enter_insert = true, ensure_blank_after = true })
end

function M.insert_asis_chunk()
  local label = prompt("Chunk label: ", "")
  local expr = prompt("Expression to cat(): ", "")

  local lines = {
    "```{r, results = 'asis'}",
    "#| label: " .. label,
    "cat(" .. expr .. ")",
    "```",
  }

  insert_template({ lines = lines, cursor_line = #lines - 1, enter_insert = true, ensure_blank_after = true })
end

function M.insert_table_chunk()
  local label = prompt("Table label: ", "tbl-")
  local caption = escape_quotes(prompt("Table caption: ", ""))
  local code = prompt("Table code: ", "|> kbl(\"markdown\")")

  local lines = {
    "```{r}",
    "#| label: " .. label,
    "#| tbl-cap: \"" .. caption .. "\"",
    "#| eval: true",
    "#| echo: false",
    code,
    "```",
  }

  insert_template({ lines = lines, cursor_line = #lines - 1, enter_insert = true, ensure_blank_after = true })
end

function M.insert_empty_r_chunk()
  local label = prompt("Chunk label (optional): ", "")
  local lines = { "```{r}" }
  if label ~= "" then
    table.insert(lines, "#| label: " .. label)
  end
  table.insert(lines, "")
  table.insert(lines, "```")

  insert_template({ lines = lines, cursor_line = #lines - 1, enter_insert = true, ensure_blank_after = true })
end

function M.insert_pagebreak()
  local lines = { "{{< pagebreak >}}" }
  insert_template({ lines = lines, cursor_line = #lines, ensure_blank_after = true })
end

return M
