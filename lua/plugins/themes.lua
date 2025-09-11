return {
  -- catppuccin - very clear and modern
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = false,
        term_colors = true, -- force terminal colors
        compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  
  -- kanagawa - beautiful clear theme
  {
    "rebelot/kanagawa.nvim",
    opts = {
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,
      theme = "wave", -- Load "wave" theme when 'background' option is not set
    },
  },
  
  -- rose-pine - minimal and clear
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "main", -- auto, main, moon, or dawn
      dark_variant = "main",
      dim_inactive_windows = false,
      extend_background_behind_borders = true,
    },
  },
  
}