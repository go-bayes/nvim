-- explicit configuration for the python language server (pyright)

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

    -- function to find virtual environment
    local function get_python_path(workspace)
      local venv_paths = {
        workspace .. "/.venv/bin/python",
        workspace .. "/venv/bin/python",
        workspace .. "/.virtualenv/bin/python",
      }

      for _, path in ipairs(venv_paths) do
        if vim.fn.executable(path) == 1 then
          return path
        end
      end

      return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
    end

    lspconfig.pyright.setup({
      capabilities = capabilities,

      before_init = function(_, config)
        local workspace = config.root_dir
        if workspace then
          config.settings.python.pythonPath = get_python_path(workspace)
        end
      end,
      settings = {
        python = {
          analysis = {
            -- type checking mode: "off", "basic", "strict"
            typeCheckingMode = "basic",
            -- automatically search for imports
            autoSearchPaths = true,
            -- use library code for types
            useLibraryCodeForTypes = true,
            -- diagnostics mode: "openFilesOnly", "workspace"
            diagnosticMode = "openFilesOnly",
          },
        },
      },
      -- configure specific filetypes
      filetypes = { "python" },
      -- set root directory patterns
      root_dir = lspconfig.util.root_pattern(
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
        ".venv",
        "venv",
        ".git"
      ),
    })
  end,
}
