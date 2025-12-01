return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local wordcount_filetypes = {
        markdown = true,
        qmd = true,
        quarto = true,
        rmd = true,
        pandoc = true,
      }

      local wordcount_component = {
        function()
          local wc = vim.fn.wordcount()
          local words = wc.visual_words > 0 and wc.visual_words or wc.words
          if words <= 0 then return "0 words" end
          local label = wc.visual_words > 0 and "sel" or "words"
          return string.format("%d %s", words, label)
        end,
        cond = function() return wordcount_filetypes[vim.bo.filetype] end,
      }

      opts.sections = opts.sections or {}
      opts.sections.lualine_z = opts.sections.lualine_z
        or { { "progress" } }
      table.insert(opts.sections.lualine_z, 1, wordcount_component)

      opts.options = opts.options or {}
      opts.options.globalstatus = true -- keep single statusline at bottom

      -- Provide a tmux-style info line at the top of each window via winbar
      opts.winbar = {
        lualine_a = { "mode" },
        lualine_b = {
          { "branch" },
          { "diff" },
        },
        lualine_c = {
          { "filename", path = 1, symbols = { modified = "[+]", readonly = "[RO]" } },
        },
        lualine_x = {},
        lualine_y = { "diagnostics" },
        lualine_z = {
          wordcount_component,
          { "location" },
        },
      }

      opts.inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          { "filename", path = 1 },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      }
    end,
  },
}
