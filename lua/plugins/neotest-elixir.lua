-- Neotest with Elixir adapter

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "jfpedroza/neotest-elixir",
    },
    keys = {
      { "<leader>tn", function() require("neotest").run.run() end,                        desc = "Nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end,     desc = "File tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end,                desc = "Test summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end,   desc = "Test output" },
    },
    opts = function(_, opts)
      opts = opts or {}
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require("neotest-elixir")({
        mix_task = "test",
        -- args = { "--trace" }, -- uncomment if you prefer trace output
      }))
      return opts
    end,
  },
}

