return {
  -- Quarto support
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("quarto").setup({
        lspFeatures = {
          enabled = false, -- Completely disable to prevent R conflicts
          chunks = "none",
          languages = {},
          diagnostics = {
            enabled = false,
            triggers = {},
          },
          completion = {
            enabled = false,
          },
        },
        keymap = {
          hover = "K",
          definition = "gd",
          rename = "<leader>rn",
          references = "gr",
          format = "<leader>gf",
        },
        -- Disable codeRunner hooks to avoid requiring molten/slime.
        -- We'll rely on iron.nvim for executing code and provide chunk motions.
        codeRunner = {
          enabled = false,
          never_run = { "yaml" },
        },
      })
    end,
    event = "VeryLazy",
    keys = {
      { "<leader>qa", ":QuartoActivate<cr>", desc = "quarto activate" },
      { "<leader>qp", ":lua require'quarto'.quartoPreview()<cr>", desc = "quarto preview" },
      { "<leader>qq", ":lua require'quarto'.quartoClosePreview()<cr>", desc = "quarto close" },
      { "<leader>qh", ":QuartoHelp ", desc = "quarto help" },
      { "<leader>qe", ":lua require'otter'.export()<cr>", desc = "quarto export" },
      { "<leader>qE", ":lua require'otter'.export(true)<cr>", desc = "quarto export overwrite" },
      { "<leader>qr", ":!quarto render %<cr>", desc = "quarto render current file" },
      { "<leader>qrr", ":QuartoSendAbove<cr>", desc = "quarto run to cursor" },
      { "<leader>qra", ":QuartoSendAll<cr>", desc = "quarto run all" },
      { "<localleader><cr>", ":QuartoSendBelow<cr>", desc = "quarto run cell" },
      { "<localleader>a", ":QuartoSendAll<cr>", desc = "quarto run all" },
    },
  },
  -- Otter for embedded language support in Quarto
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("otter").setup({
        lsp = {
          hover = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          },
        },
        buffers = {
          set_filetype = true,
        },
        handle_leading_whitespace = true,
      })
    end,
  },
  -- Pandoc citation completion
  {
    "aspeddro/cmp-pandoc.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "jmbuhr/otter.nvim",
    },
    ft = { "quarto", "markdown" },
    config = function()
      require("cmp_pandoc").setup({
        bibliography = {
          documentation = true,
          default_path = nil, -- will auto-detect from YAML frontmatter
        },
        crossref = {
          documentation = true,
          default_path = nil, -- will auto-detect from YAML frontmatter  
        }
      })
      -- Add to cmp sources when nvim-cmp is present
      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp and cmp and type(cmp.get_config) == "function" then
        local cfg = cmp.get_config()
        cfg.sources = cfg.sources or {}
        table.insert(cfg.sources, { name = "cmp_pandoc" })
        cmp.setup(cfg)
      end
    end,
  },
}
