return {
	{ -- Collection of various small independent plugins/modules
		"echasnovski/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			-- Commenting lines and blocks
			require("mini.comment").setup()

			-- Auto pairs
			require("mini.pairs").setup()

			-- Icons
			require("mini.icons").setup()

			-- Welcome screen
			require("mini.starter").setup({
				evaluate_single = true,
			})

			-- Visualize indent scope
			require("mini.indentscope").setup({
				symbol = "│",
				draw = { delay = 50 },
			})

			-- Move lines or selections
			require("mini.move").setup({
				mappings = {
					left = "<M-h>",
					right = "<M-l>",
					down = "<M-j>",
					up = "<M-k>",
				},
			})

			-- Simple and easy statusline.
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			-- cursor location to LINE:COLUMN set the section for
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_c = function()
				local session_name = require("auto-session.lib").current_session_name(true)
				return "Session: " .. (session_name or "None")
			end

			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},
}
