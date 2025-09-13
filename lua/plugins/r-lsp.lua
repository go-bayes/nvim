-- Explicit configuration for the R language server
-- Uses the recommended invocation via base R, not mason-managed binaries

return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink and type(blink.get_lsp_capabilities) == "function" then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end
    lspconfig.r_language_server.setup({
      cmd = { "R", "--slave", "-e", "options(languageserver.diagnostics=FALSE);languageserver::run()" },
      on_attach = function(_, bufnr)
        vim.diagnostic.disable(bufnr)
      end,
      capabilities = capabilities,
      settings = {},
    })
  end,
}
