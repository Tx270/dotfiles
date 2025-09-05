local session_dir = vim.fn.stdpath("data") .. "/sessions/"
vim.fn.mkdir(session_dir, "p")

local function get_session_file()
	return session_dir .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t") .. ".vim"
end

local function is_ignored_dir()
	local cwd = vim.fn.getcwd()
	local home = vim.fn.expand("~")
	local sci = home .. "/SCI"

	if cwd == home then
		return true
	end

	if vim.fn.fnamemodify(cwd, ":h") == home then
		return true
	end

	if vim.fn.fnamemodify(cwd, ":h") == sci then
		return true
	end

	return false
end

local function save_session()
	local session_file = get_session_file()

	if is_ignored_dir() then
		return
	elseif vim.fn.argc() > 0 then
		return
	end

	local ignore_filetypes = { "gitcommit", "help", "qf", "TelescopePrompt" }
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local ft = vim.api.nvim_buf_get_option(buf, "filetype")
			for _, ig in ipairs(ignore_filetypes) do
				if ft == ig then
					return
				end
			end
		end
	end

	vim.cmd("mks! " .. session_file)
end

local function load_session()
	local session_file = get_session_file()
	if vim.fn.filereadable(session_file) == 1 then
		vim.cmd("silent! source " .. session_file)
		vim.cmd("NvimTreeOpen")
		print("Session loaded: " .. session_file)
	else
		print("No session found for: " .. vim.fn.getcwd())
	end
end

vim.api.nvim_create_user_command("SaveSession", save_session, {})
vim.api.nvim_create_user_command("LoadSession", load_session, {})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			load_session()
		end
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		save_session()
	end,
})
