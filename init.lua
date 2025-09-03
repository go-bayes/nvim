-- ~/.config/nvim/init.lua  (minimal, R + Quarto ready)

-- leader + basics
vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.clipboard = "unnamedplus"

-- tidy swap/undo/backup dirs
local data = vim.fn.stdpath("state")
vim.o.directory = data .. "/swap//"
vim.o.undodir   = data .. "/undo//"
vim.o.backupdir = data .. "/backup//"
vim.o.undofile  = true

-- python provider (your venv)
vim.g.python3_host_prog = os.getenv("HOME") .. "/.venvs/nvim/bin/python3"

-- plugin manager bootstrap: lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- treesitter with enhanced language support
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "r", "python", "markdown", "latex", "json", "csv", "yaml", "lua", "vim" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- file tree explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 35 },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
      })
    end,
  },

  -- improved telescope with fzf sorting
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "%.git/", "node_modules/", "__pycache__/" },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
          },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- R integration (R.nvim) with enhanced config
  {
    "R-nvim/R.nvim",
    lazy = false,
    config = function()
      require("r").setup({
        auto_start = "on startup",
        R_args = { "--quiet", "--no-save" },
        hook = {
          on_filetype = function()
            -- rstudio-style keymaps
            vim.keymap.set("i", "<D-->", " <- ", { buffer = true, desc = "Assignment operator" })
            vim.keymap.set("n", "<D-->", "a <- <Esc>", { buffer = true, desc = "Assignment operator" })
            
            -- section comments (rstudio cmd+shift+r equivalent)
            vim.keymap.set("n", "<D-S-r>", function()
              local line = vim.api.nvim_get_current_line()
              local indent = line:match("^%s*")
              local new_line = indent .. "# " .. string.rep("-", 60) .. " ----"
              vim.api.nvim_set_current_line(new_line)
            end, { buffer = true, desc = "Insert section comment" })
            
            -- send code
            vim.keymap.set("n", "<CR>", "<Plug>RSendLine", { buffer = true })
            vim.keymap.set("v", "<CR>", "<Plug>RSendSelection", { buffer = true })
            vim.keymap.set("n", "<D-CR>", "<Plug>RSendLine", { buffer = true, desc = "Send line to R" })
            vim.keymap.set("v", "<D-CR>", "<Plug>RSendSelection", { buffer = true, desc = "Send selection to R" })
          end,
        },
      })
      -- convenience keys
      vim.keymap.set("n", "<leader>rs", ":RStart<CR>", { silent = true, desc = "Start R console" })
      vim.keymap.set("n", "<leader>rS", ":RStop<CR>", { silent = true, desc = "Stop R console" })
    end,
  },

  -- quarto with enhanced config
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("quarto").setup({
        debug = false,
        closePreviewOnExit = true,
        lspFeatures = {
          enabled = true,
          languages = { "r", "python", "julia", "bash", "html" },
        },
      })
      
      -- quarto keymaps
      vim.keymap.set("n", "<leader>qp", ":QuartoPreview<CR>", { desc = "Quarto preview" })
      vim.keymap.set("n", "<leader>qq", ":QuartoClosePreview<CR>", { desc = "Quarto close preview" })
      vim.keymap.set("n", "<leader>qh", ":QuartoHelp<CR>", { desc = "Quarto help" })
      vim.keymap.set("n", "<leader>qe", ":QuartoExport<CR>", { desc = "Quarto export" })
      
      -- rstudio-style keymaps for quarto files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "quarto", "qmd" },
        callback = function()
          vim.keymap.set("i", "<D-->", " <- ", { buffer = true, desc = "Assignment operator" })
          vim.keymap.set("n", "<D-->", "a <- <Esc>", { buffer = true, desc = "Assignment operator" })
          
          vim.keymap.set("n", "<D-S-r>", function()
            local line = vim.api.nvim_get_current_line()
            local indent = line:match("^%s*")
            local new_line = indent .. "# " .. string.rep("-", 60) .. " ----"
            vim.api.nvim_set_current_line(new_line)
          end, { buffer = true, desc = "Insert section comment" })
        end,
      })
    end,
  },

  -- enhanced autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "R-nvim/cmp-r",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = {
          { name = "cmp_r" },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  -- lsp support
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      
      -- python
      lspconfig.pyright.setup({})
      
      -- json
      lspconfig.jsonls.setup({})
      
      -- latex
      lspconfig.texlab.setup({})
    end,
  },

  -- csv support
  {
    "chrisbra/csv.vim",
    ft = "csv",
  },

  -- markdown support
  {
    "plasticboy/vim-markdown",
    ft = "markdown",
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal = 0
    end,
  },

  -- latex support
  {
    "lervag/vimtex",
    ft = { "tex", "latex" },
    config = function()
      vim.g.vimtex_view_method = "skim"  -- or "preview" on macOS
      vim.g.vimtex_compiler_method = "latexmk"
    end,
  },

  -- status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "auto" },
        sections = {
          lualine_c = { "filename", "filetype" },
        },
      })
    end,
  },

  -- colour scheme
  {
    "folke/tokyonight.nvim",
    config = function()
      vim.cmd("colorscheme tokyonight-night")
    end,
  },
})

-- open R in a right-hand vertical split when editing R / Quarto

vim.api.nvim_create_autocmd("FileType", { pattern = { "r", "rmd", "qmd", "quarto" },
  callback = function()
    -- if an R console/terminal likely exists in this tab, do nothing
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft  = vim.bo[buf].filetype
      if ft == "rout" or ft == "rconsole" then
        return
      end
    end

    -- defer to ensure plugin commands are registered
    vim.defer_fn(function()
      -- make the split on the right
      vim.cmd("vsplit | wincmd l")

      if vim.fn.exists(":RStart") == 2 then
        vim.cmd("RStart")
      elseif vim.fn.exists(":R") == 2 then
        vim.cmd("R")
      else
        -- fallback: builtin terminal running R
        vim.cmd("terminal R --quiet --no-save")
        -- (you can still use R.nvim/Nvim-R later; this just gives you a console now)
      end

      -- go back to the source pane
      vim.cmd("wincmd h")
    end, 50)  -- ~50 ms
  end,
})


-- telescope mappings (enhanced fuzzy search)
vim.keymap.set("n", "<space>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<space>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<space>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
vim.keymap.set("n", "<space>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
vim.keymap.set("n", "<space>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })

-- file tree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- rstudio-style alignment function (cmd+shift+a equivalent)
local function align_assignments()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  
  if start_line == 0 then
    start_line = vim.fn.line(".")
    end_line = start_line
  end
  
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local max_pos = 0
  
  -- find the position of the longest assignment
  for _, line in ipairs(lines) do
    local pos = line:find("<%-")
    if pos then
      max_pos = math.max(max_pos, pos - 1)
    end
  end
  
  -- align assignments
  for i, line in ipairs(lines) do
    local pos = line:find("<%-")
    if pos then
      local before = line:sub(1, pos - 1)
      local after = line:sub(pos)
      local spaces_needed = max_pos - (pos - 1)
      local new_line = before .. string.rep(" ", spaces_needed) .. after
      vim.api.nvim_buf_set_lines(0, start_line - 1 + i - 1, start_line + i - 1, false, {new_line})
    end
  end
end

-- global keymaps for rstudio-style functionality
vim.keymap.set("n", "<D-S-a>", align_assignments, { desc = "Align assignments" })
vim.keymap.set("v", "<D-S-a>", function()
  align_assignments()
  vim.cmd("normal! gv")
end, { desc = "Align assignments (visual)" })

-- alternative keymaps for non-mac users
vim.keymap.set("n", "<leader>aa", align_assignments, { desc = "Align assignments" })
vim.keymap.set("v", "<leader>aa", function()
  align_assignments()
  vim.cmd("normal! gv")  
end, { desc = "Align assignments (visual)" })

-- git directory navigation macros
local git_base = os.getenv("HOME") .. "/GIT"

-- quick navigation to common git directories
vim.keymap.set("n", "<leader>gd", function()
  vim.cmd("cd " .. git_base)
  print("Changed to GIT directory: " .. git_base)
end, { desc = "Go to GIT directory" })

vim.keymap.set("n", "<leader>gt", function()
  vim.cmd("Telescope find_files cwd=" .. git_base)
end, { desc = "Find files in GIT directory" })

vim.keymap.set("n", "<leader>gg", function()
  vim.cmd("Telescope live_grep cwd=" .. git_base)
end, { desc = "Search in GIT directory" })

-- quick access to frequently used project directories
local function navigate_to_project(project_name, description)
  return function()
    local project_path = git_base .. "/" .. project_name
    if vim.fn.isdirectory(project_path) == 1 then
      vim.cmd("cd " .. project_path)
      print("Changed to: " .. project_path)
    else
      print("Project not found: " .. project_path)
    end
  end
end

-- project-specific shortcuts (based on your directory listing)
vim.keymap.set("n", "<leader>gm", navigate_to_project("margot", "Go to margot project"), { desc = "Go to margot project" })
vim.keymap.set("n", "<leader>ge", navigate_to_project("epic-models", "Go to epic-models project"), { desc = "Go to epic-models project" })
vim.keymap.set("n", "<leader>gb", navigate_to_project("boilerplate", "Go to boilerplate project"), { desc = "Go to boilerplate project" })
vim.keymap.set("n", "<leader>gl", navigate_to_project("letters", "Go to letters project"), { desc = "Go to letters project" })
vim.keymap.set("n", "<leader>gp", navigate_to_project("templates", "Go to templates project"), { desc = "Go to templates project" })

-- telescope with git directory presets
vim.keymap.set("n", "<leader>gf", function()
  require("telescope.builtin").find_files({
    prompt_title = "GIT Files",
    cwd = git_base,
    find_command = {"find", ".", "-type", "f", "-name", "*.R", "-o", "-name", "*.qmd", "-o", "-name", "*.Rmd", "-o", "-name", "*.py", "-o", "-name", "*.md"}
  })
end, { desc = "Find R/Quarto/Python files in GIT" })

vim.keymap.set("n", "<leader>gr", function()
  require("telescope.builtin").find_files({
    prompt_title = "R Files in GIT",
    cwd = git_base,
    find_command = {"find", ".", "-type", "f", "-name", "*.R", "-o", "-name", "*.Rmd", "-o", "-name", "*.qmd"}
  })
end, { desc = "Find R/Quarto files in GIT" })

-- disable providers you don't use (optional)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

