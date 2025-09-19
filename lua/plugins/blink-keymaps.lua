return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.keymap = opts.keymap or {}
      opts.keymap["<C-y>"] = { "select_and_accept" }
      opts.keymap["<Tab>"] = { "fallback" }
    end,
  },
}
