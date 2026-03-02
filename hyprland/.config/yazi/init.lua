-- sort files in Downloads by mtime
require("folder-rules"):setup()

-- remove the status bar
require("no-status"):setup()

-- add a little padding before header bar
Header:children_add(function()
	return ui.Span(" ")
end, 500, Header.LEFT)

-- add storage % in header bar
require("fs-usage"):setup({
	format = "usage",
	style_normal = { bg = "black" },
	bar = false,
	padding = { open = "", close = " " },
})

-- add custom symbols for git plugin
th.git = th.git or {}
th.git.unknown_sign = " "
th.git.modified_sign = "M"
th.git.added_sign = "+"
th.git.untracked_sign = "?"
th.git.ignored_sign = "."
th.git.deleted_sign = "D"
th.git.updated_sign = "U"
th.git.clean_sign = " "

require("git"):setup({
	order = 1500,
})
