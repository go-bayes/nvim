-- explicit configuration for the r language server
-- uses the recommended invocation via base r, not mason-managed binaries

return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")

    -- build capabilities with blink.cmp support
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- check if blink is available and get its capabilities
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink and blink.get_lsp_capabilities then
      capabilities = blink.get_lsp_capabilities(capabilities)
    else
      -- fallback: manually set essential completion capabilities
      capabilities.textDocument = capabilities.textDocument or {}
      capabilities.textDocument.completion = {
        dynamicRegistration = false,
        completionItem = {
          snippetSupport = true,
          commitCharactersSupport = true,
          deprecatedSupport = true,
          preselectSupport = true,
          tagSupport = { valueSet = { 1 } },
          insertReplaceSupport = true,
          resolveSupport = {
            properties = { "documentation", "detail", "additionalTextEdits" },
          },
          insertTextModeSupport = { valueSet = { 1, 2 } },
          labelDetailsSupport = true,
        },
        contextSupport = true,
        insertTextMode = 1,
        completionList = {
          itemDefaults = {
            "commitCharacters",
            "editRange",
            "insertTextFormat",
            "insertTextMode",
          },
        },
      }
    end

    local diag = require("config.r_diagnostics")

    lspconfig.r_language_server.setup({
      cmd = {
        "/usr/local/bin/R",
        "--no-echo",
        "--no-restore",
        "--slave",
        "-e",
        "languageserver::run()",
      },
      on_attach = function(client, bufnr)
        diag.on_attach(client, bufnr)

        -- override the completion trigger characters for r language server
        -- the server doesn't report $ as a trigger, but it does support it
        if client.server_capabilities.completionProvider then
          client.server_capabilities.completionProvider.triggerCharacters = { ".", ":", "$", "@", "[", "," }
        end
      end,
      capabilities = capabilities,
      settings = {
        languageserver = {
          diagnostics = {
            workspace = false,
            suppressPackageStartupMessages = true,
          },
        },
        r = {
          lsp = {
            -- enable rich documentation in completions
            rich_documentation = true,
            -- enable snippet support
            snippet_support = true,
          },
        },
      },
      -- configure specific filetypes
      filetypes = { "r", "rmd", "quarto", "qmd" },
      -- set root directory patterns
      root_dir = lspconfig.util.root_pattern(".git", ".Rproj.user", "DESCRIPTION", "renv.lock", "packrat"),
    })
  end,
}
