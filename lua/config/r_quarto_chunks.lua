local M = {}

local function get_line(lnum)
  return (vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]) or ""
end

local function find_chunk_bounds_at(line)
  local cur = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  local s, e, lang = M.find_chunk_bounds()
  vim.api.nvim_win_set_cursor(0, cur)
  return s, e, lang
end

-- Find the current fenced code chunk bounds and language
-- Returns: start_lnum, end_lnum, lang (or nils if not in a chunk)
function M.find_chunk_bounds()
  local total = vim.api.nvim_buf_line_count(0)
  local cur = vim.api.nvim_win_get_cursor(0)[1]

  -- search upward for header fence
  local start_lnum, lang
  for l = cur, 1, -1 do
    local line = get_line(l)
    if line:match("^```%s*$") then
      -- hit a closing fence before finding a header, abort
      break
    end
    local header = line:match("^```%s*%{(.-)%}%s*$")
    if header then
      lang = header:match("^%s*([%w_%-%.]+)")
      start_lnum = l
      break
    end
  end
  if not start_lnum then return nil, nil, nil end

  -- search downward for closing fence
  local end_lnum
  for l = start_lnum + 1, total do
    if get_line(l):match("^```%s*$") then
      end_lnum = l
      break
    end
  end
  if not end_lnum then return nil, nil, nil end

  return start_lnum, end_lnum, lang
end

-- Returns true if cursor is inside an R chunk
function M.in_r_chunk()
  local s, e, lang = M.find_chunk_bounds()
  if not s or not e then return false, nil, nil end
  if not lang or lang:lower() ~= "r" then return false, s, e end
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  return (cur > s and cur < e), s, e
end

-- Send the current line if inside an R chunk
function M.send_line_in_chunk()
  local inside, s, e = M.in_r_chunk()
  if not inside then return end
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  if lnum <= s or lnum >= e then return end
  local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
  if line == "" then return end
  local ok, iron = pcall(require, "iron.core")
  if not ok then return end
  iron.send("r", line)
  -- move down to next non-fence line
  if lnum + 1 < e then
    vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 })
  end
end

-- Send the current paragraph (separated by blank lines) within the R chunk
function M.send_paragraph_in_chunk()
  local inside, s, e = M.in_r_chunk()
  if not inside then return end
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local start_line = cur
  local end_line = cur
  -- expand upwards to blank line or chunk start
  for l = cur - 1, s + 1, -1 do
    local t = vim.api.nvim_buf_get_lines(0, l - 1, l, false)[1] or ""
    if t:match("^%s*$") then break end
    start_line = l
  end
  -- expand downwards to blank line or chunk end
  for l = cur + 1, e - 1 do
    local t = vim.api.nvim_buf_get_lines(0, l - 1, l, false)[1] or ""
    if t:match("^%s*$") then break end
    end_line = l
  end
  if end_line < start_line then return end
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  if not lines or #lines == 0 then return end
  local ok, iron = pcall(require, "iron.core")
  if not ok then return end
  iron.send("r", lines)
end

function M.send_selection_in_chunk()
  local mode = vim.api.nvim_get_mode().mode
  local prefix = mode:sub(1, 1)
  if prefix ~= 'v' and prefix ~= 'V' and prefix ~= string.char(22) then return end

  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]
  if start_line == 0 or end_line == 0 then return end

  local s1, e1, lang1 = find_chunk_bounds_at(start_line)
  if not s1 or not e1 or not lang1 or lang1:lower() ~= "r" then return end
  local s2, e2, lang2 = find_chunk_bounds_at(end_line)
  if s2 ~= s1 or e2 ~= e1 or not lang2 or lang2:lower() ~= "r" then return end

  local first = math.max(math.min(start_line, end_line), s1 + 1)
  local last = math.min(math.max(start_line, end_line), e1 - 1)
  if last < first then return end

  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  if not lines or #lines == 0 then return end

  local ok, iron = pcall(require, "iron.core")
  if not ok then return end
  iron.send("r", lines)

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end

function M.goto_next_chunk()
  -- jump to next chunk header
  vim.fn.search([[^```\s*{]], "W")
end

function M.goto_prev_chunk()
  vim.fn.search([[^```\s*{]], "bW")
end

function M.select_current_chunk()
  local s, e = M.find_chunk_bounds()
  if not s or not e or e - s < 2 then return end
  -- select only the code, not fences
  vim.api.nvim_win_set_cursor(0, { s + 1, 0 })
  vim.cmd("normal! V")
  vim.api.nvim_win_set_cursor(0, { e - 1, 0 })
end

function M.send_current_chunk()
  local s, e, lang = M.find_chunk_bounds()
  if not s or not e or e - s < 2 then return end
  if lang and lang:lower() ~= "r" then
    vim.notify("Current chunk is not R (" .. lang .. ")", vim.log.levels.WARN)
    return
  end
  local ok, iron = pcall(require, "iron.core")
  if not ok then
    vim.notify("iron.nvim not available", vim.log.levels.ERROR)
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, s, e - 1, false)
  if #lines == 0 then return end
  iron.send("r", lines)
end

return M
