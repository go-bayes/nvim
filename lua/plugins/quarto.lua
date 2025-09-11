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
          enabled = true,
          chunks = "curly", -- 'curly' or 'all'
          languages = { "r", "python", "julia", "bash", "html" },
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
        keymap = {
          hover = "K",
          definition = "gd",
          rename = "<leader>rn",
          references = "gr",
          format = "<leader>gf",
        },
        codeRunner = {
          enabled = true,
          default_method = "molten", -- 'molten' or 'slime'
          ft_runners = {
            python = "molten",
            r = "slime",
          },
          never_run = { "yaml" },
        },
      })
    end,
    ft = { "quarto" },
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
      "hrsh7th/nvim-cmp",
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
      
      -- Add to cmp sources for nvim-cmp (fallback)
      local ok_cmp, cmp = pcall(require, "cmp")
      if ok_cmp then
        local config = cmp.get_config()
        table.insert(config.sources, { name = "cmp_pandoc" })
        cmp.setup(config)
      end
      
      -- Add to blink.cmp sources (primary completion engine)
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink then
        local sources = blink.get_config().sources
        if sources and sources.providers then
          sources.providers.cmp_pandoc = {
            name = "cmp_pandoc",
            module = "cmp_pandoc",
          }
          table.insert(sources.default, "cmp_pandoc")
        end
      end
    end,
  },
}