return {
	{ -- File explorer
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				view = { width = 35 },
				renderer = { group_empty = true },
				filters = { dotfiles = false },
			})
			vim.keymap.set("n", "<leader>e", function()
				local api = require("nvim-tree.api")

				if api.tree.is_visible() then
					api.tree.focus()
				else
					api.tree.open()
				end
			end, { desc = "Open file explorer or focus" })
		end,
	},
}
