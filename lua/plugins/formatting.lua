return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- add formatter mappings per filetype
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.r = { "styler" }
      opts.formatters_by_ft.rmd = { "quarto_fmt" }
      opts.formatters_by_ft.rmarkdown = { "quarto_fmt" }
      opts.formatters_by_ft.qmd = { "quarto_fmt" }
      opts.formatters_by_ft.quarto = { "quarto_fmt" }
      opts.formatters_by_ft.markdown = { "quarto_fmt" }
      opts.formatters_by_ft.elixir = { "mix_format" }

      -- define custom formatters
      opts.formatters = opts.formatters or {}
      opts.formatters.styler = {
        command = "R",
        args = {
          "--vanilla",
          "--quiet",
          "--slave",
          "--no-restore",
          "--no-save",
          "-e",
          "con <- file('stdin'); styler::style_text(readLines(con)); close(con)",
        },
        stdin = true,
        condition = function() return vim.fn.executable("R") == 1 end,
      }

      opts.formatters.quarto_fmt = {
        command = "quarto",
        args = { "format", "--quiet", "$FILENAME" },
        stdin = false,
        cwd = function(ctx) return vim.fs.dirname(ctx.filename) end,
        condition = function() return vim.fn.executable("quarto") == 1 end,
      }

      opts.formatters.mix_format = {
        command = "mix",
        args = { "format", "--stdin-filename", "$FILENAME", "-" },
        stdin = true,
        cwd = function(ctx) return vim.fs.dirname(ctx.filename) end,
        condition = function() return vim.fn.executable("mix") == 1 end,
      }

      -- format on save for the relevant filetypes (uses styler/quarto/mix formatters)
      opts.format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if
          ft == "r"
          or ft == "rmd"
          or ft == "rmarkdown"
          or ft == "qmd"
          or ft == "quarto"
          or ft == "markdown"
        then
          return { lsp_fallback = false, timeout_ms = 3000 }
        end
        if ft == "elixir" then
          return { lsp_fallback = false, timeout_ms = 2000 }
        end
      end

      return opts
    end,
  },
}
