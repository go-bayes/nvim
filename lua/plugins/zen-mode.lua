return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      {
        "<leader>uz",
        function()
          require("zen-mode").toggle()
        end,
        desc = "Toggle Zen mode",
      },
    },
    opts = {
      window = {
        width = 80,
        options = {
          number = true,
          relativenumber = false,
          signcolumn = "no",
        },
      },
      plugins = {
        options = {
          showcmd = true,
        },
        tmux = { enabled = false },
        kitty = { enabled = false },
      },
    },
  },
}
