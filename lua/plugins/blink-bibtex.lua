-- add bibtex completion source for blink.cmp
return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "krissen/blink-cmp-bibtex",
    },
    opts = function(_, opts)
      local default_bib = "/Users/joseph/GIT/templates/bib/references.bib"

      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.bibtex = vim.tbl_deep_extend(
        "force",
        {
          name = "BibTeX",
          module = "blink-cmp-bibtex",
          min_keyword_length = 2,
          score_offset = 10,
          async = true,
          opts = {
            filetypes = { "tex", "plaintex", "latex" },
            files = { default_bib },
          },
        },
        opts.sources.providers.bibtex or {}
      )

      opts.sources.per_filetype = opts.sources.per_filetype or {}

      local function ensure_bibtex(filetype)
        local entry = opts.sources.per_filetype[filetype]
        if entry == nil then
          opts.sources.per_filetype[filetype] = { inherit_defaults = true, "bibtex" }
          return
        end
        if type(entry) == "table" then
          if not vim.tbl_contains(entry, "bibtex") then
            table.insert(entry, "bibtex")
          end
          if entry.inherit_defaults == nil then
            entry.inherit_defaults = true
          end
        end
      end

      ensure_bibtex("tex")
      ensure_bibtex("plaintex")
      ensure_bibtex("latex")
    end,
  },
  {
    "krissen/blink-cmp-bibtex",
    config = function()
      require("blink-cmp-bibtex").setup({
        filetypes = { "tex", "plaintex", "latex" },
        files = { "/Users/joseph/GIT/templates/bib/references.bib" },
      })
    end,
  },
}
