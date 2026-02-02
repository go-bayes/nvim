return {
  "lervag/vimtex",
  ft = "tex",
  config = function()
    vim.g.vimtex_compiler_latexmk = {
      options = { "-pdf", "-bibtex", "-interaction=nonstopmode", "-synctex=1" },
    }
  end,
}
