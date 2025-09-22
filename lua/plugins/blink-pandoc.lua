-- Add Pandoc/Quarto bibliography completion to blink.cmp
return {
  {
    "jmbuhr/cmp-pandoc-references",
    event = "VeryLazy",
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}

      -- ensure the provider list exists and includes pandoc_references
      if type(opts.sources.default) == "table" and not vim.tbl_contains(opts.sources.default, "pandoc_references") then
        table.insert(opts.sources.default, 1, "pandoc_references")
      end

      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.pandoc_references = vim.tbl_deep_extend(
        "force",
        {
          name = "Citations",
          module = "cmp-pandoc-references.blink",
          score_offset = 120,
        },
        opts.sources.providers.pandoc_references or {}
      )
    end,
  },
}
