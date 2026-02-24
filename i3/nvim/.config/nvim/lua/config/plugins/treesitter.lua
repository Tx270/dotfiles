return {
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs", -- Sets main module to use for opts

		opts = {
			ensure_installed = {
				"bash",
				"fish",
				"make",
				"vim",
				"vimdoc",
				"json",
				"yaml",
				"lua",
				"luadoc",
				"python",
				"c",
				"cpp",
				"rust",
				"go",
				"javascript",
				"typescript",
				"html",
				"css",
				"scss",
				"markdown",
				"markdown_inline",
				"diff",
				"gitcommit",
				"gitignore",
				"ruby",
				"toml",
				"dockerfile",
				"sql",
			},
			-- Autoinstall languages that are not installed
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
	},
}
