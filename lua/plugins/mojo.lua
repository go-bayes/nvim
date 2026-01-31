return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.filetype.add({
        extension = {
          mojo = "mojo",
        },
      })

      local lspconfig = require("lspconfig")
      local util = lspconfig.util

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink and blink.get_lsp_capabilities then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      if not lspconfig.mojo then
        return
      end

      lspconfig.mojo.setup({
        capabilities = capabilities,
        cmd = { "mojo-lsp-server" },
        filetypes = { "mojo" },
        root_dir = util.root_pattern("mojoproject.toml", "pyproject.toml", ".git", ".venv"),
        on_new_config = function(new_config, new_root_dir)
          local venv_cmd = new_root_dir .. "/.venv/bin/mojo-lsp-server"
          if vim.fn.executable(venv_cmd) == 1 then
            new_config.cmd = { venv_cmd }
          end
        end,
      })
    end,
  },
}
