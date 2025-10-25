return {
  -- Quarto support
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    config = function()
      require("quarto").setup({
        lspFeatures = {
          enabled = true,
          chunks = "treesitter",
          languages = { "r", "python", "bash", "lua" },
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
          enabled = false,
          never_run = { "yaml" },
        },
      })
    end,
    keys = {
      { "<leader>qa", ":QuartoActivate<cr>", desc = "quarto activate" },
      {
        "<leader>qp",
        function()
          require("quarto").quartoPreview()
          vim.schedule(function()
            vim.cmd("stopinsert")
            local term_buf = vim.b.quartoOutputBuf
            if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
              pcall(vim.api.nvim_set_option_value, "buflisted", false, { buf = term_buf })
              pcall(vim.api.nvim_set_option_value, "swapfile", false, { buf = term_buf })
              pcall(vim.api.nvim_set_option_value, "filetype", "quarto-preview", { buf = term_buf })
            end
          end)
        end,
        desc = "quarto preview",
      },
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
}
