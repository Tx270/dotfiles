vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

_G.theme = "onedark"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.sessions")
require("config.lazy")
