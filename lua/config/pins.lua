local uv = vim.uv or vim.loop

local Pins = {}

local save_path = vim.fn.stdpath("data") .. "/pins.json"
local state = { items = {} }
local loaded = false

local function load()
  if loaded then
    return
  end

  local fd = uv.fs_open(save_path, "r", 438)
  if fd then
    local stat = uv.fs_fstat(fd)
    if stat and stat.size > 0 then
      local content = uv.fs_read(fd, stat.size, 0)
      if content and content ~= "" then
        local ok, parsed = pcall(vim.json.decode, content)
        if ok and type(parsed) == "table" and type(parsed.items) == "table" then
          state = parsed
        end
      end
    end
    uv.fs_close(fd)
  end

  loaded = true
end

local function save()
  if not loaded then
    return
  end

  local ok, encoded = pcall(vim.json.encode, state)
  if not ok then
    vim.notify("Pins: failed to encode state", vim.log.levels.ERROR, { title = "Pins" })
    return
  end

  local dir = vim.fn.fnamemodify(save_path, ":h")
  vim.fn.mkdir(dir, "p")

  local fd = uv.fs_open(save_path, "w", 420)
  if not fd then
    vim.notify("Pins: unable to write pins file", vim.log.levels.ERROR, { title = "Pins" })
    return
  end
  uv.fs_write(fd, encoded, 0)
  uv.fs_close(fd)
end

local function find_index(path)
  for idx, item in ipairs(state.items) do
    if item and item.path == path then
      return idx
    end
  end
end

local function sanitize_context(ctx)
  if not ctx then
    return { row = 1, col = 0 }
  end
  return {
    row = math.max(1, tonumber(ctx.row) or 1),
    col = math.max(0, tonumber(ctx.col) or 0),
  }
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Pins" })
end

function Pins.list()
  load()
  return state.items
end

function Pins.clear()
  load()
  state.items = {}
  save()
  notify("Cleared all pins")
end

function Pins.add()
  load()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    notify("Buffer has no name", vim.log.levels.WARN)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local context = { row = cursor[1], col = cursor[2] }

  local idx = find_index(path)
  if idx then
    state.items[idx].context = context
    notify("Updated pin " .. idx)
  else
    table.insert(state.items, { path = path, context = context })
    idx = #state.items
    notify("Pinned file to slot " .. idx)
  end

  save()
end

local function open_path(path, opts)
  opts = opts or {}
  local cmd = opts.command or "edit"
  local full_cmd = string.format("%s %s", cmd, vim.fn.fnameescape(path))
  local ok, err = pcall(vim.cmd, full_cmd)
  if not ok then
    return nil, err
  end
  return vim.api.nvim_get_current_buf()
end

function Pins.remove(idx)
  load()
  if not state.items[idx] then
    notify("No pin at slot " .. idx, vim.log.levels.WARN)
    return
  end

  local removed = table.remove(state.items, idx)
  save()
  notify("Removed pin: " .. vim.fn.fnamemodify(removed.path, ":."))
end

function Pins.select(idx, opts)
  load()
  local item = state.items[idx]
  if not item then
    notify("No pin at slot " .. idx, vim.log.levels.WARN)
    return
  end

  local path = item.path
  if path == "" then
    notify("Pinned path is empty", vim.log.levels.WARN)
    return
  end

  if vim.fn.filereadable(path) == 0 then
    notify("File not found. Removing pin " .. idx, vim.log.levels.WARN)
    table.remove(state.items, idx)
    save()
    return
  end

  local bufnr, err = open_path(path, opts)
  if not bufnr then
    notify("Failed to open pin: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  local ctx = sanitize_context(item.context)
  local lines = vim.api.nvim_buf_line_count(bufnr)
  local row = math.min(ctx.row, math.max(lines, 1))
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
  local col = math.min(ctx.col, #line)
  vim.api.nvim_win_set_cursor(0, { row, col })

  state.items[idx].context = { row = row, col = col }
  save()
end

function Pins.menu()
  load()
  if #state.items == 0 then
    notify("No pins yet", vim.log.levels.INFO)
    return
  end

  local entries = {}
  for idx, item in ipairs(state.items) do
    local label = string.format("%d. %s", idx, vim.fn.fnamemodify(item.path, ":."))
    entries[idx] = { idx = idx, label = label }
  end

  vim.ui.select(entries, {
    prompt = "Pinned files",
    format_item = function(entry)
      return entry.label
    end,
  }, function(choice)
    if choice then
      Pins.select(choice.idx)
    end
  end)
end

return Pins
