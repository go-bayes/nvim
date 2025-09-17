-- Explicit configuration for the R language server
-- Uses the recommended invocation via base R, not mason-managed binaries

return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument = capabilities.textDocument or {}
    capabilities.textDocument.completion = capabilities.textDocument.completion or {}
    capabilities.textDocument.completion.completionItem =
      capabilities.textDocument.completion.completionItem or {}
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
    capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
    capabilities.textDocument.completion.contextSupport = true
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink and type(blink.get_lsp_capabilities) == "function" then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end
    capabilities.textDocument.completion = capabilities.textDocument.completion or {}
    capabilities.textDocument.completion.completionItem =
      capabilities.textDocument.completion.completionItem or {}
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
    capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
    capabilities.textDocument.completion.contextSupport = true

    local diag = require("config.r_diagnostics")

    lspconfig.r_language_server.setup({
      cmd = {
        "R",
        "--vanilla",
        "--quiet",
        "--slave",
        "-e",
        [[options(languageserver.diagnostics = TRUE); languageserver::run()]],
      },
      on_attach = function(client, bufnr)
        diag.on_attach(client, bufnr)
      end,
      capabilities = capabilities,
      settings = {
        languageserver = {
          diagnostics = {
            workspace = false,
            suppressPackageStartupMessages = true,
          },
        },
      },
    })
  end,
}
