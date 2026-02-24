return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvimtools/none-ls-extras.nvim", -- Dodajemy zależność do none-ls-extras
	},
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				-- Przykład: użycie flake8 z none-ls-extras
				require("none-ls.diagnostics.flake8"),
			},
		})
	end,
}
