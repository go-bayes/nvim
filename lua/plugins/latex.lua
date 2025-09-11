return {
  -- LaTeX support with VimTeX
  {
    "lervag/vimtex",
    lazy = false, -- load immediately for .tex files
    init = function()
      -- vimtex configuration
      vim.g.vimtex_view_method = "skim" -- use skim on macos
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        aux_dir = "",
        out_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        hooks = {},
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
      
      -- disable some vimtex features for performance
      vim.g.vimtex_syntax_enabled = 1
      vim.g.vimtex_syntax_conceal_disable = 1
      vim.g.vimtex_quickfix_enabled = 1
      vim.g.vimtex_imaps_enabled = 0
      vim.g.vimtex_indent_enabled = 1
      vim.g.vimtex_complete_enabled = 1
      vim.g.vimtex_compiler_progname = "nvr"
      
      -- set pdf viewer options for skim
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
    end,
    ft = { "tex", "latex" },
    keys = {
      { "<localleader>ll", "<cmd>VimtexCompile<cr>", desc = "VimTeX Compile" },
      { "<localleader>lv", "<cmd>VimtexView<cr>", desc = "VimTeX View" },
      { "<localleader>lc", "<cmd>VimtexClean<cr>", desc = "VimTeX Clean" },
      { "<localleader>ls", "<cmd>VimtexStop<cr>", desc = "VimTeX Stop" },
      { "<localleader>lt", "<cmd>VimtexTocToggle<cr>", desc = "VimTeX TOC Toggle" },
      { "<localleader>le", "<cmd>VimtexErrors<cr>", desc = "VimTeX Errors" },
    },
  },
}