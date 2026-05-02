-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Remove trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Trim trailing whitespace on save",
  group = vim.api.nvim_create_augroup("trim_whitespace", { clear = true }),
  callback = function()
    vim.cmd([[ %s/\s\+$//e ]])
  end,
})

-- Dynamic line numbers
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  desc = "Disable relative numbers in insert mode",
  group = vim.api.nvim_create_augroup("number_toggle", { clear = true }),
  callback = function()
    vim.opt.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  desc = "Enable relative numbers in normal mode",
  group = vim.api.nvim_create_augroup("number_toggle", { clear = false }),
  callback = function()
    vim.opt.relativenumber = true
  end,
})
