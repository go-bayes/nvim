-- Insert RStudio-style section headers in R and Quarto
-- Example line: "# My Section ----"

local M = {}

local function is_in_r_chunk()
  local ok, chunks = pcall(require, "config.r_quarto_chunks")
  if not ok then return false end
  local inside = chunks.in_r_chunk and select(1, chunks.in_r_chunk())
  return inside == true
end

local function build_hash_header(title, level)
  local hashes = string.rep("#", level)
  return { string.format("%s %s ----", hashes, title), "" }
end

local function build_underline_header(title, char)
  local width = 60
  local underline = string.rep(char, width)
  return { string.format("# %s", title), "# " .. underline, "" }
end

local function insert_header(level)
  local title = vim.fn.input("Section title: ")
  if title == nil or title == "" then return end
  local lines = build_hash_header(title, level)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  -- If inside an R chunk in prose buffers, ensure we don't place on fences
  if vim.bo.filetype ~= "r" and is_in_r_chunk() then
    -- ok to insert at current row; fences are handled by caller's cursor
  end
  -- Build insertion block with optional blank line above
  local insert_block = {}
  local need_blank_above = true
  if row > 1 then
    local prev = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1] or ""
    if prev:match("^%s*$") then
      need_blank_above = false
    end
  end
  if need_blank_above then table.insert(insert_block, "") end
  vim.list_extend(insert_block, lines)
  vim.api.nvim_buf_set_lines(0, row, row, false, insert_block)
  -- Place cursor on the blank line after the header and enter insert mode
  local advance = #insert_block
  vim.api.nvim_win_set_cursor(0, { row + advance, 0 })
  vim.cmd("startinsert")
end

local function insert_underline(char)
  local title = vim.fn.input("Section title: ")
  if title == nil or title == "" then return end
  local lines = build_underline_header(title, char)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local insert_block = {}
  local need_blank_above = true
  if row > 1 then
    local prev = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1] or ""
    if prev:match("^%s*$") then need_blank_above = false end
  end
  if need_blank_above then table.insert(insert_block, "") end
  vim.list_extend(insert_block, lines)
  vim.api.nvim_buf_set_lines(0, row, row, false, insert_block)
  local advance = #insert_block
  vim.api.nvim_win_set_cursor(0, { row + advance, 0 })
  vim.cmd("startinsert")
end

-- Boxed header builders
local function box_chars(style)
  if style == 'heavy' then
    return { tl = '╔', tr = '╗', bl = '╚', br = '╝', h = '═', v = '║' }
  else
    return { tl = '┌', tr = '┐', bl = '└', br = '┘', h = '─', v = '│' }
  end
end

local function build_box_header(title, opts)
  opts = opts or {}
  local style = opts.style or 'thin'
  local pad = opts.pad or 1
  local maxw = opts.max_width or 72
  local c = box_chars(style)
  local inner = #title + pad * 2
  local width = math.max(inner, 30)
  width = math.min(width, maxw)
  local top = c.tl .. string.rep(c.h, width) .. c.tr
  local mid
  do
    local space_left = math.floor((width - #title) / 2)
    local space_right = width - #title - space_left
    mid = c.v .. string.rep(' ', space_left) .. title .. string.rep(' ', space_right) .. c.v
  end
  local bot = c.bl .. string.rep(c.h, width) .. c.br
  return { '# ' .. top, '# ' .. mid, '# ' .. bot, '' }
end

local function insert_box(style)
  local title = vim.fn.input("Section title: ")
  if title == nil or title == "" then return end
  local lines = build_box_header(title, { style = style or 'thin' })
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local insert_block = {}
  local need_blank_above = true
  if row > 1 then
    local prev = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1] or ""
    if prev:match("^%s*$") then need_blank_above = false end
  end
  if need_blank_above then table.insert(insert_block, "") end
  vim.list_extend(insert_block, lines)
  vim.api.nvim_buf_set_lines(0, row, row, false, insert_block)
  local advance = #insert_block
  vim.api.nvim_win_set_cursor(0, { row + advance, 0 })
  vim.cmd("startinsert")
end

local function replace_visual_with_box(style)
  local b, e, text = visual_text()
  if text == nil or text == "" then return end
  local insert_block = {}
  local need_blank_above = true
  if b > 1 then
    local prev = vim.api.nvim_buf_get_lines(0, b - 2, b - 1, false)[1] or ""
    if prev:match("^%s*$") then need_blank_above = false end
  end
  if need_blank_above then table.insert(insert_block, "") end
  local header_lines = build_box_header(text, { style = style or 'thin' })
  vim.list_extend(insert_block, header_lines)
  vim.api.nvim_buf_set_lines(0, b - 1, e, false, insert_block)
  local advance = #insert_block
  vim.api.nvim_win_set_cursor(0, { (b - 1) + advance, 0 })
  vim.cmd("startinsert")
end

-- Template header (Title/Author/Date)
local function insert_template()
  local title = vim.fn.input("Title: ")
  if not title or title == '' then return end
  local user = os.getenv('USER') or ''
  local author = vim.fn.input("Author (" .. user .. "): ")
  if author == '' then author = user end
  local defdate = os.date('%Y-%m-%d')
  local date = vim.fn.input("Date (" .. defdate .. "): ")
  if date == '' then date = defdate end
  local width = 60
  local dash = string.rep('-', width)
  local block = {
    '',
    '# ' .. dash,
    '# Title: ' .. title,
    '# Author: ' .. author,
    '# Date: ' .. date,
    '# ' .. dash,
    '',
  }
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, block)
  vim.api.nvim_win_set_cursor(0, { row + #block, 0 })
  vim.cmd('startinsert')
end

local function visual_text()
  local b = vim.fn.getpos("'<")[2]
  local e = vim.fn.getpos("'>")[2]
  local lines = vim.api.nvim_buf_get_lines(0, b - 1, e, false)
  local text = table.concat(lines, " ")
  text = text:gsub("^%s+", ""):gsub("%s+$", "")
  return b, e, text
end

local function replace_visual_with_header(builder)
  local b, e, text = visual_text()
  if text == nil or text == "" then return end
  local row = b - 1
  local insert_block = {}
  local need_blank_above = true
  if b > 1 then
    local prev = vim.api.nvim_buf_get_lines(0, b - 2, b - 1, false)[1] or ""
    if prev:match("^%s*$") then need_blank_above = false end
  end
  if need_blank_above then table.insert(insert_block, "") end
  local header_lines = builder(text)
  vim.list_extend(insert_block, header_lines)
  -- replace selected lines with header block
  vim.api.nvim_buf_set_lines(0, b - 1, e, false, insert_block)
  -- move cursor to blank line after header
  local advance = #insert_block
  vim.api.nvim_win_set_cursor(0, { (b - 1) + advance, 0 })
  vim.cmd("startinsert")
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "rmd", "qmd", "quarto" },
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    -- Normal mode header creators (avoid <leader>rh conflict with iron hide)
    vim.keymap.set("n", "<leader>r1", function() insert_header(1) end, { buffer = buf, desc = "Header: # title ----" })
    vim.keymap.set("n", "<leader>r2", function() insert_header(2) end, { buffer = buf, desc = "Header: ## title ----" })
    vim.keymap.set("n", "<leader>r3", function() insert_header(3) end, { buffer = buf, desc = "Header: ### title ----" })
    vim.keymap.set("n", "<leader>r-", function() insert_underline('-') end, { buffer = buf, desc = "Header: underline -" })
    vim.keymap.set("n", "<leader>r=", function() insert_underline('=') end, { buffer = buf, desc = "Header: underline =" })
    vim.keymap.set("n", "<leader>rB", function() insert_box('thin') end, { buffer = buf, desc = "Header: boxed (thin)" })
    vim.keymap.set("n", "<leader>rH", function() insert_box('heavy') end, { buffer = buf, desc = "Header: boxed (heavy)" })
    vim.keymap.set("n", "<leader>rT", insert_template, { buffer = buf, desc = "Header: template Title/Author/Date" })

    -- Visual mode: turn selection into header
    vim.keymap.set("v", "<leader>r1", function()
      replace_visual_with_header(function(text) return build_hash_header(text, 1) end)
    end, { buffer = buf, desc = "Header from selection: # ----" })
    vim.keymap.set("v", "<leader>r2", function()
      replace_visual_with_header(function(text) return build_hash_header(text, 2) end)
    end, { buffer = buf, desc = "Header from selection: ## ----" })
    vim.keymap.set("v", "<leader>r3", function()
      replace_visual_with_header(function(text) return build_hash_header(text, 3) end)
    end, { buffer = buf, desc = "Header from selection: ### ----" })
    vim.keymap.set("v", "<leader>r-", function()
      replace_visual_with_header(function(text) return build_underline_header(text, '-') end)
    end, { buffer = buf, desc = "Header from selection: underline -" })
    vim.keymap.set("v", "<leader>r=", function()
      replace_visual_with_header(function(text) return build_underline_header(text, '=') end)
    end, { buffer = buf, desc = "Header from selection: underline =" })
    vim.keymap.set("v", "<leader>rB", function()
      replace_visual_with_box('thin')
    end, { buffer = buf, desc = "Header from selection: boxed (thin)" })
    vim.keymap.set("v", "<leader>rH", function()
      replace_visual_with_box('heavy')
    end, { buffer = buf, desc = "Header from selection: boxed (heavy)" })
  end,
  desc = "R headers (RStudio-style)",
})

return M
