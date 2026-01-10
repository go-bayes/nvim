return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local uv = vim.uv or vim.loop
      local clean_cache = {}
      local wordcount_cache = {}
      local wordcount_timers = {}
      local wordcount_inflight = {}
      local wordcount_refresh_ms = 400
      local pandoc_filter = vim.fn.stdpath("config") .. "/scripts/pandoc-wordcount.lua"
      local pandoc_available = vim.fn.executable("pandoc") == 1
        and vim.fn.filereadable(pandoc_filter) == 1
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

      local function current_winid()
        local winid = vim.g.statusline_winid
        if winid and vim.api.nvim_win_is_valid(winid) then
          return winid
        end
        return vim.api.nvim_get_current_win()
      end

      local function normalize_line(line)
        for _, apostrophe in ipairs(curly_apostrophes) do
          line = line:gsub(apostrophe, "'")
        end
        return line
      end

      local function count_clean_words(bufnr, end_pos)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return 0
        end

        local tick = vim.api.nvim_buf_get_changedtick(bufnr)
        if not end_pos then
          local cached = clean_cache[bufnr]
          if cached and cached.tick == tick then
            return cached.count
          end
        end

        local lines
        if end_pos then
          local end_row = math.max(end_pos[1] or 1, 1)
          local end_col = math.max(end_pos[2] or 0, 0)
          lines = vim.api.nvim_buf_get_lines(bufnr, 0, end_row, false)
          if #lines == 0 then
            return 0
          end
          local last = lines[#lines] or ""
          lines[#lines] = last:sub(1, end_col + 1)
        else
          lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        end

        local in_yaml = false
        local in_code = false
        local in_comment = false
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
              if in_comment then
                local close_start, close_end = line:find("%-%->")
                if close_start then
                  line = line:sub(close_end + 1)
                  in_comment = false
                else
                  goto continue
                end
              end

              local open_start = line:find("<!%-%-")
              if open_start then
                local close_start, close_end = line:find("%-%->", open_start + 4)
                if close_start then
                  line = line:sub(1, open_start - 1) .. " " .. line:sub(close_end + 1)
                else
                  line = line:sub(1, open_start - 1)
                  in_comment = true
                end
              end

              line = line:gsub("`.-`", " ")
              line = normalize_line(line)
              for _ in line:gmatch("[A-Za-z0-9]+[A-Za-z0-9'`-]*") do
                count = count + 1
              end
            end
          end

          ::continue::
        end

        if not end_pos then
          clean_cache[bufnr] = { tick = tick, count = count }
        end
        return count
      end

      local function is_target_filetype(ft)
        return ft == "markdown"
          or ft == "qmd"
          or ft == "quarto"
          or ft:match("^markdown")
          or ft:match("^quarto")
      end

      local function wordcount_for_bufnr(bufnr)
        local ok, wc = pcall(vim.api.nvim_buf_call, bufnr, function()
          return vim.fn.wordcount()
        end)
        if ok and type(wc) == "table" then
          return wc
        end
        return vim.fn.wordcount()
      end

      local function count_words_from_text(text)
        local count = 0
        for _ in text:gmatch("[A-Za-z0-9]+[A-Za-z0-9'`-]*") do
          count = count + 1
        end
        return count
      end

      local function update_wordcount(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end

        local tick = vim.api.nvim_buf_get_changedtick(bufnr)
        local cached = wordcount_cache[bufnr]
        if cached and cached.tick == tick then
          return
        end
        if wordcount_inflight[bufnr] then
          return
        end

        local ft = vim.bo[bufnr].filetype
        if not is_target_filetype(ft) or not pandoc_available then
          return
        end

        wordcount_inflight[bufnr] = true
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local text = table.concat(lines, "\n")
        local cmd = {
          "pandoc",
          "--from",
          "markdown+yaml_metadata_block",
          "--to",
          "plain",
          "--lua-filter",
          pandoc_filter,
        }

        if vim.system then
          vim.system(cmd, { text = text }, function(result)
            vim.schedule(function()
              wordcount_inflight[bufnr] = nil
              if not vim.api.nvim_buf_is_valid(bufnr) then
                return
              end
              if result.code ~= 0 then
                wordcount_cache[bufnr] = nil
              else
                local count = count_words_from_text(result.stdout or "")
                wordcount_cache[bufnr] = { tick = tick, count = count }
              end
              local ok, lualine = pcall(require, "lualine")
              if ok then
                lualine.refresh({ place = { "statusline", "winbar" } })
              end
            end)
          end)
        else
          local output = vim.fn.system(cmd, text)
          wordcount_inflight[bufnr] = nil
          if vim.v.shell_error ~= 0 then
            wordcount_cache[bufnr] = nil
          else
            local count = count_words_from_text(output or "")
            wordcount_cache[bufnr] = { tick = tick, count = count }
          end
        end
      end

      local function schedule_wordcount_update(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        if not pandoc_available then
          return
        end
        local ft = vim.bo[bufnr].filetype
        if not is_target_filetype(ft) then
          return
        end
        if wordcount_timers[bufnr] then
          wordcount_timers[bufnr]:stop()
          wordcount_timers[bufnr]:close()
        end
        local timer = uv.new_timer()
        wordcount_timers[bufnr] = timer
        timer:start(wordcount_refresh_ms, 0, function()
          timer:stop()
          timer:close()
          wordcount_timers[bufnr] = nil
          vim.schedule(function()
            update_wordcount(bufnr)
          end)
        end)
      end

      local function refresh_lualine()
        local ok, lualine = pcall(require, "lualine")
        if ok then
          lualine.refresh({ place = { "statusline", "winbar" } })
        end
      end

      local wordcount_component = {
        function()
          local bufnr = current_bufnr()
          local wc = wordcount_for_bufnr(bufnr)
          local visual_words = tonumber(wc.visual_words) or 0
          if visual_words > 0 then
            return string.format("%d sel", visual_words)
          end

          local winid = current_winid()
          local cursor = vim.api.nvim_win_get_cursor(winid)
          local cursor_words = count_clean_words(bufnr, cursor)
          if cursor_words <= 0 then
            cursor_words = tonumber(wc.cursor_words) or 0
          end

          local tick = vim.api.nvim_buf_get_changedtick(bufnr)
          local cached = wordcount_cache[bufnr]
          local total_words = (cached and cached.tick == tick) and cached.count or 0
          if total_words <= 0 then
            total_words = count_clean_words(bufnr)
          end
          if total_words <= 0 then
            total_words = tonumber(wc.words) or 0
          end
          if total_words <= 0 then return "0 words" end
          if cursor_words > total_words then
            cursor_words = total_words
          end
          return string.format("%d/%d words", cursor_words, total_words)
        end,
        cond = function()
          local bufnr = current_bufnr()
          return is_target_filetype(vim.bo[bufnr].filetype)
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

      local refresh_group = vim.api.nvim_create_augroup("LualineWordcountRefresh", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "TextChangedP" }, {
        group = refresh_group,
        callback = function(args)
          schedule_wordcount_update(args.buf)
          if is_target_filetype(vim.bo[args.buf].filetype) then
            refresh_lualine()
          end
        end,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = refresh_group,
        callback = function(args)
          if is_target_filetype(vim.bo[args.buf].filetype) then
            refresh_lualine()
          end
        end,
      })

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
