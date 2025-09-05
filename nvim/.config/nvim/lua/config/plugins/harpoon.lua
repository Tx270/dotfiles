return {
	{ -- Tab replacement
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			local conf = require("telescope.config").values
			local function toggle_telescope(harpoon_files)
				local file_paths = {}
				for _, item in ipairs(harpoon_files.items) do
					table.insert(file_paths, item.value)
				end

				require("telescope.pickers")
					.new({}, {
						prompt_title = "Harpoon",
						finder = require("telescope.finders").new_table({
							results = file_paths,
						}),
						previewer = conf.file_previewer({}),
						sorter = conf.generic_sorter({}),
					})
					:find()
			end

			vim.keymap.set("n", "<C-e>", function()
				toggle_telescope(harpoon:list())
			end, { desc = "Open Harpoon window" })

			vim.keymap.set("n", "<C-a>", function()
				harpoon:list():add()
			end, { desc = "Add file to Harpoon list" })

			vim.keymap.set("n", "<C-d>", function()
				harpoon:list():remove()
			end, { desc = "Remove current file from Harpoon list" })

			vim.keymap.set("n", "<C-1>", function()
				harpoon:list():select(1)
			end, { desc = "Go to Harpoon file 1" })

			vim.keymap.set("n", "<C-2>", function()
				harpoon:list():select(2)
			end, { desc = "Go to Harpoon file 2" })

			vim.keymap.set("n", "<C-3>", function()
				harpoon:list():select(3)
			end, { desc = "Go to Harpoon file 3" })

			vim.keymap.set("n", "<C-4>", function()
				harpoon:list():select(4)
			end, { desc = "Go to Harpoon file 4" })

			vim.keymap.set("n", "<C-5>", function()
				harpoon:list():select(5)
			end, { desc = "Go to Harpoon file 5" })

			vim.keymap.set("n", "<C-6>", function()
				harpoon:list():select(6)
			end, { desc = "Go to Harpoon file 6" })

			vim.keymap.set("n", "<C-7>", function()
				harpoon:list():select(7)
			end, { desc = "Go to Harpoon file 7" })

			vim.keymap.set("n", "<C-8>", function()
				harpoon:list():select(8)
			end, { desc = "Go to Harpoon file 8" })

			vim.keymap.set("n", "<C-9>", function()
				harpoon:list():select(9)
			end, { desc = "Go to Harpoon file 9" })

			vim.keymap.set("n", "<C-0>", function()
				harpoon:list():select(10)
			end, { desc = "Go to Harpoon file 10" })

			vim.keymap.set("n", "<C-,>", function()
				harpoon:list():prev()
			end, { desc = "Go to previous Harpoon file" })

			vim.keymap.set("n", "<C-.>", function()
				harpoon:list():next()
			end, { desc = "Go to next Harpoon file" })
		end,
	},
}
