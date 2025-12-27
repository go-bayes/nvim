-- Proven iron.nvim configuration pattern from GitHub discussion #319
-- This follows the exact working pattern used by the community

return {
  "Vigemus/iron.nvim",
  main = "iron.core",
  ft = { "r", "rmd", "quarto", "qmd", "python" },
  cmd = { "IronRepl", "IronReplHere", "IronRestart", "IronSend", "IronFocus", "IronHide" },
  keys = {
    { "<space>rs", "<cmd>IronRepl<cr>", desc = "Start REPL" },
    { "<space>rr", "<cmd>IronRestart<cr>", desc = "Restart REPL" },
    { "<space>rf", "<cmd>IronFocus<cr>", desc = "Focus REPL" },
    { "<space>rh", "<cmd>IronHide<cr>", desc = "Hide REPL" },
    -- Ensure pressing send keys loads the plugin and applies its keymaps
    { "<space>sl", mode = { "n" }, desc = "Iron send line (load)" },
    { "<space>sc", mode = { "n", "v" }, desc = "Iron send motion/selection (load)" },
    { "<space>sf", mode = { "n" }, desc = "Iron send file (load)" },
    { "<space>su", mode = { "n" }, desc = "Iron send until cursor (load)" },
    { "<space>sp", mode = { "n" }, desc = "Iron send paragraph (load)" },
    { "<space>s<space>", mode = { "n" }, desc = "Iron interrupt (load)" },
  },
  opts = function()
    -- Choose radian if available, otherwise fallback to base R
    local r_cmd
    if vim.fn.executable("radian") == 1 then
      r_cmd = { vim.fn.exepath("radian") }
    elseif vim.fn.executable("R") == 1 then
      local r_path = vim.fn.exepath("R")
      if r_path ~= nil and r_path ~= "" then
        r_cmd = { r_path, "--quiet", "--no-save" }
      end
    end

    if not r_cmd then
      for _, candidate in ipairs({ "/opt/homebrew/bin/R", "/usr/local/bin/R" }) do
        if vim.fn.executable(candidate) == 1 then
          r_cmd = { candidate, "--quiet", "--no-save" }
          break
        end
      end
    end

    if not r_cmd then
      vim.notify("iron.nvim: R executable not found on PATH", vim.log.levels.WARN)
      r_cmd = { "R", "--quiet", "--no-save" }
    end

    local view = require("iron.view")
    return {
      config = {
        scratch_repl = false,
        repl_definition = {
          r = {
            command = r_cmd,
            -- Use bracketed paste so multi-line sends (functions, loops) stay intact
            format = require("iron.fts.common").bracketed_paste,
          },
          python = {
            command = { "bash", "-c", [[
if [ -x .venv/bin/ipython ]; then
  exec .venv/bin/ipython --no-autoindent
elif [ -x venv/bin/ipython ]; then
  exec venv/bin/ipython --no-autoindent
elif command -v ipython >/dev/null 2>&1; then
  exec ipython --no-autoindent
else
  exec python3
fi
]] },
            format = require("iron.fts.common").bracketed_paste,
          },
          quarto = {
            command = r_cmd,
            format = require("iron.fts.common").bracketed_paste,
          },
          qmd = {
            command = r_cmd,
            format = require("iron.fts.common").bracketed_paste,
          },
          rmd = {
            command = r_cmd,
            format = require("iron.fts.common").bracketed_paste,
          },
          markdown = {
            command = r_cmd,
            format = require("iron.fts.common").bracketed_paste,
          },
        },
        -- Provide both horizontal-bottom and vertical-right split modes
        repl_open_cmd = {
          view.split.botright("40%"),          -- cmd_1: bottom split 40% height (default)
          view.split.vertical.botright("40%"), -- cmd_2: right split 40% width
        },
      },
      keymaps = {
        -- Toggle/shape controls
        toggle_repl = "<space>rs",
        toggle_repl_with_cmd_1 = "<space>rb", -- bottom horizontal
        toggle_repl_with_cmd_2 = "<space>rv", -- right vertical
        restart_repl = "<space>rr",
        -- Sending
        send_motion = "<space>sc",
        visual_send = "<space>sc",
        send_file = "<space>sf",
        send_line = "<space>sl",
        send_until_cursor = "<space>su",
        send_paragraph = "<space>sp",
        -- Mark operations (useful for repeated execution)
        send_mark = "<space>sm",
        mark_motion = "<space>mc",
        mark_visual = "<space>mc",
        remove_mark = "<space>md",
        -- Control operations
        cr = "<space>s<cr>",
        interrupt = "<space>s<space>",  -- interrupt running R code
        exit = "<space>sq",              -- quit R session
        clear = "<space>cl",             -- clear REPL screen
      },
      highlight = { italic = true },
    }
  end,
  config = function(_, opts)
    local iron = require("iron.core")
    local marks = require("iron.marks")
    iron.setup(opts)

    local function get_node_at_cursor()
      if vim.treesitter and vim.treesitter.get_node then
        return vim.treesitter.get_node({ bufnr = 0 })
      end
      local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
      if ok then
        return ts_utils.get_node_at_cursor()
      end
      return nil
    end

    local function send_python_block()
      if vim.bo.filetype ~= "python" then
        return false
      end
      local node = get_node_at_cursor()
      if not node then
        return false
      end

      local function is_block(n)
        local t = n:type()
        return t == "function_definition" or t == "class_definition"
      end

      local target = node
      while target and not is_block(target) do
        target = target:parent()
      end
      if not target then
        return false
      end
      local parent = target:parent()
      if parent and parent:type() == "decorated_definition" then
        target = parent
      end

      local start_row, _, end_row, end_col = target:range()
      if end_row < start_row then
        return false
      end
      local last_row = end_row
      local end_exclusive = end_row + 1
      if end_col == 0 and end_row > start_row then
        last_row = end_row - 1
        end_exclusive = end_row
      end
      local lines = vim.api.nvim_buf_get_lines(0, start_row, end_exclusive, false)
      if #lines == 0 then
        return false
      end

      local last_line = vim.api.nvim_buf_get_lines(0, last_row, last_row + 1, false)[1] or ""
      local last_col = math.max(vim.fn.strwidth(last_line) - 1, 0)
      marks.set({
        from_line = start_row,
        from_col = 0,
        to_line = last_row,
        to_col = last_col,
      })
      iron.send(nil, lines)
      return true
    end

    local function send_r_block()
      if vim.bo.filetype ~= "r" then
        return false
      end
      local node = get_node_at_cursor()
      if not node then
        return false
      end

      local function is_func(n)
        return n:type() == "function_definition"
      end

      local target = node
      while target and not is_func(target) do
        target = target:parent()
      end
      if not target then
        return false
      end

      local parent = target:parent()
      if parent then
        local pt = parent:type()
        if pt == "binary_operator" or pt == "left_assignment" or pt == "assignment" then
          target = parent
        end
      end

      local start_row, _, end_row, end_col = target:range()
      if end_row < start_row then
        return false
      end
      local last_row = end_row
      local end_exclusive = end_row + 1
      if end_col == 0 and end_row > start_row then
        last_row = end_row - 1
        end_exclusive = end_row
      end
      local lines = vim.api.nvim_buf_get_lines(0, start_row, end_exclusive, false)
      if #lines == 0 then
        return false
      end

      local last_line = vim.api.nvim_buf_get_lines(0, last_row, last_row + 1, false)[1] or ""
      local last_col = math.max(vim.fn.strwidth(last_line) - 1, 0)
      marks.set({
        from_line = start_row,
        from_col = 0,
        to_line = last_row,
        to_col = last_col,
      })
      iron.send(nil, lines)
      return true
    end

    local function move_cursor_after_send(fallback_line)
      local region = marks.get()
      local next_line = fallback_line
      if region then
        next_line = (region.to_line or region.from_line) + 2
      end

      if not next_line then
        return
      end

      local bufnr = vim.api.nvim_get_current_buf()
      local total = vim.api.nvim_buf_line_count(bufnr)
      local target = math.min(math.max(next_line, 1), total)
      local line = vim.api.nvim_buf_get_lines(bufnr, target - 1, target, false)[1] or ""
      local col = #(line:match("^%s*") or "")
      vim.api.nvim_win_set_cursor(0, { target, col })
    end

    local function send_line_and_advance()
      local current_line = vim.api.nvim_win_get_cursor(0)[1]
      iron.send_line()
      move_cursor_after_send(current_line + 1)
    end

    local function send_paragraph_and_advance()
      local current_line = vim.api.nvim_win_get_cursor(0)[1]
      if send_python_block() then
        vim.defer_fn(function()
          move_cursor_after_send(current_line + 1)
        end, 60)
        return
      end
      if send_r_block() then
        vim.defer_fn(function()
          move_cursor_after_send(current_line + 1)
        end, 60)
        return
      end
      iron.send_paragraph()
      vim.defer_fn(function()
        move_cursor_after_send(current_line + 1)
      end, 100)
    end

    local function send_visual_and_advance()
      local end_line = vim.fn.line("'>")
      iron.visual_send()
      vim.defer_fn(function()
        move_cursor_after_send(end_line + 1)
      end, 60)
    end

    vim.keymap.set("n", "<leader>sl", send_line_and_advance, { desc = "Send line and advance", silent = true })
    vim.keymap.set("n", "<leader>sp", send_paragraph_and_advance, { desc = "Send paragraph and advance", silent = true })
    vim.keymap.set("v", "<leader>sc", send_visual_and_advance, { desc = "Send selection and advance", silent = true })
  end,
}
