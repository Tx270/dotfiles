-- [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

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
