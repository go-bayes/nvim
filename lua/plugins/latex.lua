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
      { "<leader>lc", "<cmd>VimtexClean<cr>", desc = "Vimtex clean aux files" },
      { "<leader>lC", "<cmd>VimtexClean!<cr>", desc = "Vimtex full clean" },
      { "<leader>lr", "<cmd>VimtexClean<cr><cmd>VimtexCompile<cr>", desc = "Clean and recompile" },
    },
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_compiler_latexmk = {
        callback = 1,
        continuous = 0,
        executable = "latexmk",
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
          "-f",
        },
      }

      local default_bib = "/Users/joseph/GIT/templates/bib/references.bib"
      local uv = vim.uv or vim.loop

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("vimtex_default_bib", { clear = true }),
        pattern = { "tex", "plaintex", "latex" },
        callback = function()
          local bibs = vim.b.vimtex_bibliographies
          if bibs == nil or #bibs == 0 then
            if uv and uv.fs_stat(default_bib) then
              vim.b.vimtex_bibliographies = { default_bib }
            end
          end
        end,
      })
    end,
  },
}
