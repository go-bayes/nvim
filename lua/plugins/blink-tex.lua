-- add vimtex omnifunc completion for tex filetypes via blink.cmp
return {
  "saghen/blink.cmp",
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("blink_tex_cite_map", { clear = true }),
      pattern = { "tex", "plaintex", "latex" },
      callback = function()
        local function should_trigger_cite()
          local line = vim.fn.getline(".")
          local col = vim.fn.col(".")
          local before = line:sub(1, col - 1)
          return before:match("\\\\citep$") or before:match("\\\\citet$") or before:match("\\\\cite$")
        end

        local show = function()
          local ok, blink = pcall(require, "blink.cmp")
          if ok then
            blink.show()
          end
        end

        vim.keymap.set("i", "{", function()
          local trigger = should_trigger_cite()
          if trigger then
            vim.schedule(show)
          end
          return "{"
        end, { buffer = true, expr = true, desc = "Insert { and trigger cite completion" })

        vim.keymap.set("i", "<leader>lb", show, { buffer = true, desc = "Blink complete" })
        vim.keymap.set("n", "<leader>lb", show, { buffer = true, desc = "Blink complete" })
      end,
    })
  end,
  opts = function(_, opts)
    opts.sources = opts.sources or {}
    opts.sources.per_filetype = opts.sources.per_filetype or {}

    local function ensure_omni(filetype)
      local entry = opts.sources.per_filetype[filetype]
      if entry == nil then
        opts.sources.per_filetype[filetype] = { inherit_defaults = true, "omni" }
        return
      end
      if type(entry) == "table" then
        if not vim.tbl_contains(entry, "omni") then
          table.insert(entry, "omni")
        end
        if entry.inherit_defaults == nil then
          entry.inherit_defaults = true
        end
      end
    end

    ensure_omni("tex")
    ensure_omni("plaintex")
    ensure_omni("latex")
  end,
}
