-- Leader must be set before plugins
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Options, keymaps, autocmds first
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Bootstrap lazy.nvim and load our plugins
require("config.lazy")

-- Custom mappings not tied to plugins
require("config.r_mappings")
require("config.python_mappings")
require("config.quarto_chunk_keymaps")
require("config.r_headers")
