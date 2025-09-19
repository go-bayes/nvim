return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.config").setup({
        -- Install parsers needed for R.nvim and Quarto
        ensure_installed = {
          "r",
          "markdown",
          "markdown_inline",
          "query",
          "lua",
          -- Elixir
          "elixir",
          "heex",
          "eex",
          -- Core
          "vim",
          "vimdoc",
          "python",
          "bash",
          "yaml",
        },
        
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,
        
        -- Automatically install missing parsers when entering buffer
        auto_install = true,
        
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        
        -- Indentation based on treesitter
        indent = {
          enable = true,
        },
        
        -- Incremental selection
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },
}
