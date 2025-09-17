-- Elixir LSP setup for LazyVim
-- Ensures ElixirLS is installed via mason-lspconfig and configures server settings

return {
  -- Ensure Next LS is installed (via Mason)
  {
    "mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "nextls") then
        table.insert(opts.ensure_installed, "nextls")
      end
    end,
  },

  -- Configure Next LS via lspconfig (managed by LazyVim)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nextls = {},
        -- Explicitly disable elixirls so both don't attach
        elixirls = { enabled = false },
      },
    },
  },
}
