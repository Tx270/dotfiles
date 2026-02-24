-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require("lazy").setup({
	{ import = "config.themes" },
	{ -- Apply dynamic theme from global var
		"nvim-lua/plenary.nvim",
		priority = 1001,
		config = function()
			local theme = _G.theme or "industry"
			pcall(vim.cmd, "colorscheme " .. theme)
		end,
	},
	{ import = "config.plugins" },
	-- https://github.com/nvim-lua/kickstart.nvim/blob/master/lua/kickstart/plugins/debug.lua
	-- https://github.com/nvim-lua/kickstart.nvim/blob/master/lua/kickstart/plugins/lint.lua
}, {
	ui = {
		icons = {},
	},
})
