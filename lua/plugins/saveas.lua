-- Simple, reliable "Save As" and "Save Copy As" prompts using built-in completion
return {
  {
    "LazyVim/LazyVim",
    config = function()
      local function ensure_parent_dir(path)
        local dir = vim.fn.fnamemodify(path, ":h")
        if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, "p")
        end
      end

      local function default_filename_with_ext(ext)
        local name = vim.fn.expand("%:t")
        if name == nil or name == "" then name = "new_file" end
        if ext and #ext > 0 then
          name = vim.fn.fnamemodify(name, ":r") .. "." .. ext
        end
        return name
      end

      local function prompt_and_write(write_mode, prompt, default_path, force_ext)
        local path = vim.fn.input(prompt, default_path, "file")
        if not path or path == "" then return end
        -- Normalize and handle directory only input (or trailing slash)
        local is_dir = (vim.fn.isdirectory(path) == 1) or path:match("/$") ~= nil
        if is_dir then
          local fname = default_filename_with_ext(force_ext)
          local name = vim.fn.input("File name: ", fname)
          if not name or name == "" then return end
          path = (path:gsub("/*$", "")) .. "/" .. name
        elseif force_ext and #force_ext > 0 then
          -- If user provided a full path but we want .qmd, ensure extension
          path = vim.fn.fnamemodify(path, ":r") .. "." .. force_ext
        end
        ensure_parent_dir(path)
        local cmd = write_mode and "write " or "saveas "
        vim.cmd(cmd .. vim.fn.fnameescape(path))
      end

      -- Save As: renames buffer to new path
      vim.keymap.set("n", "<leader>sA", function()
        local default = vim.fn.expand("%:p")
        if default == nil or default == "" then
          default = vim.fn.getcwd() .. "/new_file"
        end
        prompt_and_write(false, "Save As: ", default, nil)
      end, { desc = "Save As…", silent = true })

      -- (Removed sC and sq mappings per request to avoid conflicts)
    end,
  },
}
