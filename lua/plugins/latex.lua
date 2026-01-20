return {
  -- Ensure LaTeX language servers are installed (via Mason)
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
      add("texlab")
      add("ltex")
    end,
  },

  -- Configure LaTeX language servers
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.texlab = opts.servers.texlab or {}
      opts.servers.ltex = opts.servers.ltex or {
        filetypes = { "tex", "plaintex" },
      }
    end,
  },

  {
    "lervag/vimtex",
    ft = { "tex", "plaintex", "latex" },
    keys = {
      { "<leader>ll", "<cmd>VimtexCompile<cr>", desc = "Vimtex compile" },
      { "<leader>lv", "<cmd>VimtexView<cr>", desc = "Vimtex view PDF" },
    },
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "build",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
        },
      }
    end,
  },
}
