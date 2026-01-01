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

      local clean_cache = {}
      local curly_apostrophes = {
        string.char(0xE2, 0x80, 0x99), -- U+2019
        string.char(0xE2, 0x80, 0x98), -- U+2018
      }

      local function current_bufnr()
        local winid = vim.g.statusline_winid
        if winid and vim.api.nvim_win_is_valid(winid) then
          return vim.api.nvim_win_get_buf(winid)
        end
        return vim.api.nvim_get_current_buf()
      end

      local function normalize_line(line)
        for _, apostrophe in ipairs(curly_apostrophes) do
          line = line:gsub(apostrophe, "'")
        end
        return line
      end

      local function count_clean_words(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return 0
        end

        local tick = vim.api.nvim_buf_get_changedtick(bufnr)
        local cached = clean_cache[bufnr]
        if cached and cached.tick == tick then
          return cached.count
        end

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local in_yaml = false
        local in_code = false
        local count = 0

        if lines[1] and lines[1]:match("^%s*---%s*$") then
          in_yaml = true
        end

        local function is_fence(line)
          return line:match("^%s*```") or line:match("^%s*~~~")
        end

        for idx, line in ipairs(lines) do
          if in_yaml then
            if idx > 1 and (line:match("^%s*---%s*$") or line:match("^%s*%.%.%.%s*$")) then
              in_yaml = false
            end
          else
            if is_fence(line) then
              in_code = not in_code
            elseif not in_code and not line:match("^%s*{{<%s*pagebreak%s*>}}%s*$") then
              line = normalize_line(line)
              for _ in line:gmatch("[A-Za-z0-9]+[A-Za-z0-9'`-]*") do
                count = count + 1
              end
            end
          end
        end

        clean_cache[bufnr] = { tick = tick, count = count }
        return count
      end

      local wordcount_component = {
        function()
          local wc = vim.fn.wordcount()
          if wc.visual_words > 0 then
            return string.format("%d sel", wc.visual_words)
          end

          local bufnr = current_bufnr()
          local words = count_clean_words(bufnr)
          if words <= 0 then return "0 words" end
          return string.format("%d words", words)
        end,
        cond = function()
          local bufnr = current_bufnr()
          return wordcount_filetypes[vim.bo[bufnr].filetype]
        end,
      }

      opts.sections = opts.sections or {}
      opts.sections.lualine_z = opts.sections.lualine_z
        or { { "progress" } }
      table.insert(opts.sections.lualine_z, 1, wordcount_component)

      opts.options = opts.options or {}
      opts.options.globalstatus = true -- keep single statusline at bottom
      opts.options.refresh = {
        statusline = 500,
        winbar = 500,
        tabline = 1000,
      }

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
