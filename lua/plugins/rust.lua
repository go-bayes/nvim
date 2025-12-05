-- Rust development setup for LazyVim

return {
  -- Add rust to treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "rust", "toml" })
    end,
  },

  -- Rustaceanvim - enhanced rust support
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    init = function()
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              check = {
                command = "check",
              },
            },
          },
        },
      }
    end,
  },

  -- Ensure rust-analyzer is installed via Mason
  {
    "mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "rust_analyzer") then
        table.insert(opts.ensure_installed, "rust_analyzer")
      end
    end,
  },

  -- Add crates.nvim for Cargo.toml dependency management
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        cmp = { enabled = true },
      },
    },
  },
}
