local uv = vim.uv or vim.loop

local function find_quarto_root(file)
  local dir = vim.fs.dirname(file)
  if dir and uv.fs_stat(vim.fs.joinpath(dir, "_quarto.yml")) then
    return dir
  end
  for parent in vim.fs.parents(dir or file) do
    if uv.fs_stat(vim.fs.joinpath(parent, "_quarto.yml")) then
      return parent
    end
  end
  return dir
end

local function detect_output_dir(root)
  if not root then return nil end
  local cfg = vim.fs.joinpath(root, "_quarto.yml")
  if not uv.fs_stat(cfg) then return nil end
  local ok, lines = pcall(vim.fn.readfile, cfg)
  if not ok then return nil end
  for _, line in ipairs(lines) do
    local match = line:match("output%-dir:%s*([%w%-%._/]+)")
    if match then
      match = match:gsub("[\"']", "")
      return match
    end
  end
  return nil
end

local function guess_html_output(file)
  local dir = vim.fs.dirname(file)
  local stem = vim.fs.basename(file):gsub("%.[^.]+$", "")
  local root = find_quarto_root(file)
  local project_output = detect_output_dir(root)

  local candidate_dirs = {}
  local function add_dir(path)
    if path and path ~= "" then
      candidate_dirs[#candidate_dirs + 1] = path
    end
  end

  add_dir(dir)
  if project_output and root then
    add_dir(vim.fs.joinpath(root, project_output))
  end
  for _, folder in ipairs({ "docs", "_site", "_book" }) do
    add_dir(vim.fs.joinpath(dir or "", folder))
    if root then
      add_dir(vim.fs.joinpath(root, folder))
    end
  end

  local seen = {}
  for _, base in ipairs(candidate_dirs) do
    local path = vim.fs.joinpath(base, stem .. ".html")
    if not seen[path] and uv.fs_stat(path) then
      return path
    end
    seen[path] = true
  end

  if root then
    local found = vim.fs.find(stem .. ".html", { path = root, limit = 1 })
    if #found > 0 then
      return found[1]
    end
  end

  return nil
end

local function run_quarto_render(fmt, opts)
  opts = opts or {}
  if vim.fn.executable("quarto") ~= 1 then
    vim.notify("quarto CLI not found on PATH", vim.log.levels.ERROR, { title = "Quarto render" })
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Save the buffer before rendering with Quarto", vim.log.levels.WARN, { title = "Quarto render" })
    return
  end

  local args = { "quarto", "render", file }
  local label = "default"
  if fmt and fmt ~= "" then
    label = fmt
    vim.list_extend(args, { "--to", fmt })
  end

  vim.notify(("Rendering %s (%s)…"):format(vim.fn.fnamemodify(file, ":t"), label), vim.log.levels.INFO, { title = "Quarto" })
  local output = vim.fn.systemlist(args)
  local status = vim.v.shell_error
  if status == 0 then
    vim.notify(("Quarto render (%s) complete"):format(label), vim.log.levels.INFO, { title = "Quarto" })
    if opts.open_html and fmt == "html" then
      local target = guess_html_output(file)
      if target then
        if vim.fn.executable("open") == 1 then
          vim.fn.jobstart({ "open", target }, { detach = true })
          vim.notify(("Opened HTML output → %s"):format(vim.fn.fnamemodify(target, ":.")), vim.log.levels.INFO, { title = "Quarto" })
        else
          vim.notify(("Rendered HTML at %s (install macOS 'open' to auto-launch)"):format(target), vim.log.levels.INFO, { title = "Quarto" })
        end
      else
        vim.notify("Rendered HTML but could not locate the output file. If you use a custom output directory, please open it manually.", vim.log.levels.WARN, { title = "Quarto" })
      end
    end
  else
    local message = table.concat(output, "\n")
    vim.notify(("Quarto render (%s) failed:\n%s"):format(label, message), vim.log.levels.ERROR, { title = "Quarto" })
  end
end

return {
  -- Quarto support
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    config = function()
      require("quarto").setup({
        lspFeatures = {
          enabled = true,
          chunks = "treesitter",
          languages = { "r", "python", "bash", "lua" },
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
        keymap = {
          hover = "K",
          definition = "gd",
          rename = "<leader>rn",
          references = "gr",
          format = "<leader>gf",
        },
        codeRunner = {
          enabled = true,
          default_method = "iron",
          ft_runners = {
            yaml = function()
              vim.notify("Skipping YAML front matter (no runner)", vim.log.levels.DEBUG, { title = "Quarto" })
            end,
          },
          never_run = { "yaml" },
        },
      })
    end,
    keys = {
      { "<leader>qa", ":QuartoActivate<cr>", desc = "quarto activate" },
      {
        "<leader>qp",
        function()
          require("quarto").quartoPreview()
          vim.schedule(function()
            vim.cmd("stopinsert")
            local term_buf = vim.b.quartoOutputBuf
            if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
              pcall(vim.api.nvim_set_option_value, "buflisted", false, { buf = term_buf })
              pcall(vim.api.nvim_set_option_value, "swapfile", false, { buf = term_buf })
              pcall(vim.api.nvim_set_option_value, "filetype", "quarto-preview", { buf = term_buf })
            end
          end)
        end,
        desc = "quarto preview",
      },
      { "<leader>qq", ":lua require'quarto'.quartoClosePreview()<cr>", desc = "quarto close" },
      { "<leader>qh", ":QuartoHelp ", desc = "quarto help" },
      { "<leader>qe", ":lua require'otter'.export()<cr>", desc = "quarto export" },
      { "<leader>qE", ":lua require'otter'.export(true)<cr>", desc = "quarto export overwrite" },
      { "<leader>qr", desc = "+render" },
      { "<leader>qra", function() run_quarto_render() end, desc = "Render (default output)" },
      { "<leader>qrh", function() run_quarto_render("html", { open_html = true }) end, desc = "Render HTML (and open)" },
      { "<leader>qrp", function() run_quarto_render("pdf") end, desc = "Render PDF" },
      { "<leader>qrr", ":QuartoSendAbove<cr>", desc = "quarto run to cursor" },
      { "<localleader><cr>", ":QuartoSendBelow<cr>", desc = "quarto run cell" },
      { "<localleader>a", ":QuartoSendAll<cr>", desc = "quarto run all" },
    },
  },

  -- Otter for embedded language support in Quarto
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("otter").setup({
        lsp = {
          hover = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          },
        },
        buffers = {
          set_filetype = true,
        },
        handle_leading_whitespace = true,
      })
    end,
  },
}
