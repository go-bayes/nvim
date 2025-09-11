return {
  {
    "R-nvim/R.nvim",
    ft = { "r", "rmd", "quarto" },
    config = function()
      require("r").setup({
        R_args = { "--quiet", "--no-save" },
        min_editor_width = 72,
        rconsole_width = 78,
        rconsole_height = 15,
        auto_start = "on startup",
        objbr_auto_start = false,  -- disable object browser to avoid clutter
      })
      
      -- auto-start R and set up vertical layout
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "r", "rmd", "quarto" },
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          -- Multiple key combinations for pipe and assignment (Kitty compatible)
          vim.keymap.set("i", "<M-p>", " |> ", { buffer = bufnr })
          vim.keymap.set("i", "<A-p>", " |> ", { buffer = bufnr })
          vim.keymap.set("i", "<leader>p", " |> ", { buffer = bufnr })
          
          vim.keymap.set("i", "<M-=>", " <- ", { buffer = bufnr })
          vim.keymap.set("i", "<A-=>", " <- ", { buffer = bufnr })
          vim.keymap.set("i", "<leader>=", " <- ", { buffer = bufnr })
          
          -- keymap to switch to vertical layout
          vim.keymap.set("n", "<leader>rv", function()
            -- find R console window and make it vertical
            local wins = vim.api.nvim_list_wins()
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              local bufname = vim.api.nvim_buf_get_name(buf)
              if bufname:match("R_Console") or bufname:match("term://.*R") then
                vim.api.nvim_set_current_win(win)
                vim.cmd("wincmd L")  -- move to far right (vertical)
                vim.cmd("wincmd h")  -- return to source
                break
              end
            end
          end, { buffer = bufnr, desc = "Switch R console to vertical" })
          
          -- keymap to switch to horizontal layout  
          vim.keymap.set("n", "<leader>rh", function()
            local wins = vim.api.nvim_list_wins()
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              local bufname = vim.api.nvim_buf_get_name(buf)
              if bufname:match("R_Console") or bufname:match("term://.*R") then
                vim.api.nvim_set_current_win(win)
                vim.cmd("wincmd J")  -- move to bottom (horizontal)
                vim.cmd("wincmd k")  -- return to source
                break
              end
            end
          end, { buffer = bufnr, desc = "Switch R console to horizontal" })
          
          -- automatically start R console with proper layout
          vim.defer_fn(function()
            if vim.fn.exists(":RStart") > 0 then
              vim.cmd("RStart")
              -- ensure proper window layout after R starts
              vim.defer_fn(function()
                -- find R console window and organize layout
                local wins = vim.api.nvim_list_wins()
                for _, win in ipairs(wins) do
                  local buf = vim.api.nvim_win_get_buf(win)
                  local bufname = vim.api.nvim_buf_get_name(buf)
                  if bufname:match("R_Console") or bufname:match("term://.*R") then
                    vim.api.nvim_set_current_win(win)
                    vim.cmd("wincmd L")  -- move R console to right
                    vim.cmd("wincmd h")  -- return to source file
                    break
                  end
                end
              end, 1000)
            end
          end, 500)
        end,
      })
    end,
  },
  {
    "godlygeek/tabular",
    cmd = { "Tabularize" },
    keys = {
      { "<leader>a=", ":Tabularize /=<CR>", mode = "v", desc = "Align on =" },
      { "<leader>a<", ":Tabularize / <-<CR>", mode = "v", desc = "Align on <-" },
    },
  },
}