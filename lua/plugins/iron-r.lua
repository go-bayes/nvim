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
            -- Some R consoles echo bracketed paste markers like "01~".
            -- Use plain format to avoid sending those markers.
            format = require("iron.fts.common").plain,
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

    local function move_cursor_to_next_nonblank(start_line)
      local bufnr = vim.api.nvim_get_current_buf()
      local total = vim.api.nvim_buf_line_count(bufnr)
      if total == 0 then
        return
      end

      local function is_chunk_boundary(line)
        if line == "" then
          return false
        end

        local ft = vim.bo.filetype
        if ft == "quarto" or ft == "qmd" or ft == "markdown" then
          return line:match("^%s*```")
        end

        return false
      end

      local target = math.min(math.max(start_line, 1), total)
      for line_nr = target, total do
        local text = vim.api.nvim_buf_get_lines(bufnr, line_nr - 1, line_nr, false)[1] or ""
        if text:match("%S") and not is_chunk_boundary(text) then
          local indent = text:match("^%s*") or ""
          vim.api.nvim_win_set_cursor(0, { line_nr, #indent })
          return
        end
      end

      vim.api.nvim_win_set_cursor(0, { total, 0 })
    end

    local function advance_after_send(fallback_start, delay)
      -- iron.send_paragraph defers execution, so allow an optional delay before fetching marks
      local retries = 2
      local function move()
        local region = marks.get()
        if region then
          local next_line = (region.to_line or region.from_line) + 2
          move_cursor_to_next_nonblank(next_line)
        elseif retries > 0 then
          retries = retries - 1
          vim.defer_fn(move, 60)
          return
        elseif fallback_start then
          move_cursor_to_next_nonblank(fallback_start)
        end
      end

      if delay and delay > 0 then
        vim.defer_fn(move, delay)
      else
        move()
      end
    end

    local function send_line_and_advance()
      local current_line = vim.api.nvim_win_get_cursor(0)[1]
      iron.send_line()
      advance_after_send(current_line + 1, 0)
    end

    local function send_paragraph_and_advance()
      local current_line = vim.api.nvim_win_get_cursor(0)[1]
      iron.send_paragraph()
      advance_after_send(current_line + 1, 160)
    end

    vim.keymap.set("n", "<leader>sl", send_line_and_advance, { desc = "Send line and advance", silent = true })
    vim.keymap.set("n", "<leader>sp", send_paragraph_and_advance, { desc = "Send paragraph and advance", silent = true })
  end,
}
