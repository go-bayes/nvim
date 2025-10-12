return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.globalstatus = true -- keep single statusline at bottom

      -- Provide a tmux-style info line at the top of each window via winbar
      opts.winbar = {
        lualine_a = { "mode" },
        lualine_b = {
          { "branch" },
          { "diff" },
        },
        lualine_c = {
          { "filename", path = 1, symbols = { modified = "[+]", readonly = "[RO]" } },
        },
        lualine_x = {},
        lualine_y = { "diagnostics" },
        lualine_z = {
          { "location" },
        },
      }

      opts.inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          { "filename", path = 1 },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      }
    end,
  },
}
