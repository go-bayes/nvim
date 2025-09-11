return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- add R formatter
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.r = { "styler" }
      opts.formatters_by_ft.rmd = { "styler" }
      opts.formatters_by_ft.quarto = { "styler" }
      
      -- define the styler formatter
      opts.formatters = opts.formatters or {}
      opts.formatters.styler = {
        command = "R",
        args = {
          "--slave",
          "--no-restore",
          "--no-save",
          "-e",
          "con <- file('stdin'); styler::style_text(readLines(con)); close(con)",
        },
        stdin = true,
      }
      
      return opts
    end,
  },
}