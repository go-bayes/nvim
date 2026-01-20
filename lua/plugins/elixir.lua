-- Elixir LSP setup for LazyVim
-- Ensures Next LS is installed via mason-lspconfig and configures server settings

return {
  -- Ensure Next LS is installed (via Mason)
  {
    "mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      local ensure = opts.ensure_installed
      local function add(name)
        if not vim.tbl_contains(ensure, name) then
          table.insert(ensure, name)
        end
      end
      add("nextls")
    end,
  },

  -- Configure Next LS via lspconfig (managed by LazyVim)
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.nextls = opts.servers.nextls or {}
      opts.servers.elixirls = opts.servers.elixirls or { enabled = false }
    end,
  },
}
