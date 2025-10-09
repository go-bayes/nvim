-- Proven iron.nvim configuration pattern from GitHub discussion #319
-- This follows the exact working pattern used by the community

return {
  "Vigemus/iron.nvim",
  main = "iron.core",
  ft = { "r", "rmd", "quarto", "qmd" },
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
      r_cmd = { "radian" }
    else
      r_cmd = { "R", "--quiet", "--no-save" }
    end

    local view = require("iron.view")
    return {
      config = {
        scratch_repl = false,
        repl_definition = {
          r = {
            command = r_cmd,
            format = require("iron.fts.common").bracketed_paste, -- use standard bracketed paste
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
}
