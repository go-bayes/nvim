local function apply_tahoe(opts)
  local ok, tahoe = pcall(require, "tahoe.theme")
  if not ok then
    vim.notify("Tahoe theme module not found", vim.log.levels.ERROR)
    return
  end
  local silent = opts and opts.silent or false
  tahoe.apply({ silent = silent })
  vim.g.active_colorscheme = "tahoe"
end

vim.api.nvim_create_user_command("TahoeTheme", function()
  apply_tahoe({ silent = false })
end, { desc = "Switch to the Tahoe theme" })

vim.keymap.set("n", "<leader>uH", function()
  apply_tahoe({ silent = false })
end, { desc = "Switch to Tahoe (Clear Dark)" })

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    apply_tahoe({ silent = true })
  end,
})

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1100,
    opts = {
      flavour = "mocha",
      background = { light = "latte", dark = "mocha" },
      integrations = { cmp = true, gitsigns = true, telescope = true, treesitter = true },
      custom_highlights = function(colors)
        return {
          WinSeparator = { fg = colors.surface2, bg = colors.base },
        }
      end,
    },
    config = function(_, opts)
      local catppuccin = require("catppuccin")
      catppuccin.setup(opts)

      -- Ensure a visible separator character between window splits
      vim.opt.fillchars:append({ vert = "│" })

      local flavours = { latte = true, frappe = true, macchiato = true, mocha = true }
      local function apply(flavour, silent)
        flavour = flavour or opts.flavour or "mocha"
        if not flavours[flavour] then
          vim.notify("Unknown Catppuccin flavour: " .. flavour, vim.log.levels.ERROR)
          return
        end

        if vim.g.colors_name == "catppuccin" and vim.g.catppuccin_flavour_current == flavour then
          vim.g.active_colorscheme = "catppuccin"
          if not silent then vim.notify("Catppuccin " .. flavour .. " already active") end
          return
        end

        vim.g.catppuccin_flavour = flavour
        vim.cmd.colorscheme("catppuccin-" .. flavour)
        vim.g.catppuccin_flavour_current = flavour
        vim.g.active_colorscheme = "catppuccin"
        if not silent then vim.notify("Catppuccin → " .. flavour) end
      end

      apply(nil, true)

      vim.api.nvim_create_user_command("CatppuccinTheme", function(params)
        local flavour = params.args ~= "" and params.args or nil
        apply(flavour)
      end, {
        nargs = "?",
        complete = function()
          return { "latte", "frappe", "macchiato", "mocha" }
        end,
      })

      vim.keymap.set("n", "<leader>uc", function()
        apply("mocha")
      end, { desc = "Switch to Catppuccin (mocha)" })
    end,
  },
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
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 850,
    opts = {
      compile = false,
      dimInactive = true,
      background = { dark = "wave", light = "lotus" },
    },
    config = function(_, opts)
      local kanagawa = require("kanagawa")
      kanagawa.setup(opts)

      local variants = { wave = "kanagawa-wave", dragon = "kanagawa-dragon", lotus = "kanagawa-lotus" }
      local function apply(style, silent)
        style = style or opts.background.dark or "wave"
        if not variants[style] then
          vim.notify("Unknown Kanagawa style: " .. style, vim.log.levels.ERROR)
          return
        end

        if vim.g.colors_name == variants[style] then
          vim.g.active_colorscheme = "kanagawa"
          if not silent then vim.notify("Kanagawa " .. style .. " already active") end
          return
        end

        if style == "lotus" then
          vim.o.background = "light"
        else
          vim.o.background = "dark"
        end

        kanagawa.load(style)
        vim.g.active_colorscheme = "kanagawa"
        vim.g.kanagawa_style_current = style
        if not silent then vim.notify("Kanagawa → " .. style) end
      end

      vim.api.nvim_create_user_command("KanagawaTheme", function(params)
        local style = params.args ~= "" and params.args or nil
        apply(style)
      end, {
        nargs = "?",
        complete = function() return vim.tbl_keys(variants) end,
      })

      vim.keymap.set("n", "<leader>uk", function()
        apply("wave")
      end, { desc = "Switch to Kanagawa (wave)" })
      vim.keymap.set("n", "<leader>uK", function()
        apply("dragon")
      end, { desc = "Switch to Kanagawa (dragon)" })
    end,
  },
  {
    "mcchrish/zenbones.nvim",
    lazy = false,
    priority = 840,
    dependencies = { "rktjmp/lush.nvim" },
    config = function()
      local backgrounds = { dark = true, light = true }
      local function apply(background, silent)
        background = background or "dark"
        if not backgrounds[background] then
          vim.notify("Duckbones background must be 'dark' or 'light'", vim.log.levels.ERROR)
          return
        end

        if vim.g.colors_name == "duckbones" and vim.o.background == background then
          vim.g.active_colorscheme = "duckbones"
          if not silent then vim.notify("Duckbones (" .. background .. ") already active") end
          return
        end

        vim.o.background = background
        vim.cmd.colorscheme("duckbones")
        vim.g.duckbones_background = background
        vim.g.active_colorscheme = "duckbones"
        if not silent then vim.notify("Duckbones → " .. background) end
      end

      vim.api.nvim_create_user_command("DuckbonesTheme", function(params)
        local background = params.args ~= "" and params.args or nil
        apply(background)
      end, {
        nargs = "?",
        complete = function() return { "dark", "light" } end,
      })

      vim.keymap.set("n", "<leader>ud", function()
        apply("dark")
      end, { desc = "Switch to Duckbones (dark)" })
      vim.keymap.set("n", "<leader>uD", function()
        apply("light")
      end, { desc = "Switch to Duckbones (light)" })
    end,
  },
}
