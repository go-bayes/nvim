return {
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local function apply_nord(opts)
        local silent = opts and opts.silent
        if vim.g.colors_name == "nord" then
          if not silent then vim.notify("Nord already active") end
          vim.g.active_colorscheme = "nord"
          return
        end

        vim.cmd("highlight clear")
        vim.cmd.colorscheme("nord")
        vim.g.active_colorscheme = "nord"
        if not silent then vim.notify("Nord enabled") end
      end

      apply_nord({ silent = true })

      vim.api.nvim_create_user_command("NordTheme", function()
        apply_nord()
      end, {})
      vim.keymap.set("n", "<leader>un", ":NordTheme<CR>", { desc = "Switch to Nord theme" })
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 900,
    opts = { style = "night", transparent = false },
    config = function(_, opts)
      local tn = require("tokyonight")
      local function apply(style, transparent)
        tn.setup(vim.tbl_extend("force", opts, { style = style, transparent = transparent }))
        vim.cmd.colorscheme("tokyonight")
        vim.g.tokyonight_style_current = style
        vim.g.tokyonight_transparent = transparent and true or false
        vim.g.active_colorscheme = "tokyonight"
      end

      local styles = { "storm", "night", "moon", "day" }
      vim.g.tokyonight_style_current = opts.style or styles[1]
      vim.g.tokyonight_transparent = opts.transparent and true or false

      vim.api.nvim_create_user_command("TokyoNightCycle", function()
        local cur = vim.g.tokyonight_style_current or opts.style or styles[1]
        local idx = 1
        for i, s in ipairs(styles) do if s == cur then idx = i break end end
        local next_style = styles[(idx % #styles) + 1]
        vim.cmd("highlight clear")
        apply(next_style, vim.g.tokyonight_transparent)
        vim.notify("TokyoNight → " .. next_style)
      end, {})
      vim.keymap.set("n", "<leader>ut", ":TokyoNightCycle<CR>", { desc = "Cycle TokyoNight theme" })

      vim.api.nvim_create_user_command("TokyoNightTransparent", function()
        local cur_style = vim.g.tokyonight_style_current or opts.style or styles[1]
        local cur_tr = vim.g.tokyonight_transparent and true or false
        apply(cur_style, not cur_tr)
        vim.notify("TokyoNight transparent: " .. tostring(not cur_tr))
      end, {})
      vim.keymap.set("n", "<leader>uT", ":TokyoNightTransparent<CR>", { desc = "Toggle TokyoNight transparent" })
    end,
  },
}
