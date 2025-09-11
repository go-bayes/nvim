return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-file-browser.nvim",
    },
    config = function()
      -- load telescope file browser extension
      require("telescope").load_extension("file_browser")
      
      -- setup save as keymap
      vim.keymap.set("n", "<leader>sA", function()
        require("telescope").extensions.file_browser.file_browser({
          prompt_title = "Save As...",
          select_buffer = true,
          attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
              local entry = require("telescope.actions.state").get_selected_entry()
              local actions = require("telescope.actions")
              actions.close(prompt_bufnr)

              vim.cmd("saveas " .. entry.path)
            end)
            return true
          end,
        })
      end, { desc = "Save As with File Browser" })
    end,
  },
}