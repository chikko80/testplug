local init = require("better-window")

local api = vim.api

local M = {}

function M.on_select(bufnr)
	local linenr = vim.api.nvim_win_get_cursor(0)[1]
	local bufnumbers = api.nvim_buf_get_var(bufnr, "bufnumbers")
	local selected_bufnr = bufnumbers[linenr]
	api.nvim_buf_delete(bufnr, { force = true })

	local win_id = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win_id, selected_bufnr)
end

function M.show_popup()

	local win_id = vim.api.nvim_get_current_win()
	local buf_id = vim.api.nvim_get_current_buf()
	local editors_per_win = init.get_windows_manager():getEditorGroup(win_id)

	-- bufnumbers to bufnames
	local bufnames = {}
	local bufnumbers = {}

	for i = #editors_per_win.items, 1, -1 do
		local item = editors_per_win.items[i]
		-- exclude current buffer
		if item ~= buf_id then
			local bufname = vim.api.nvim_buf_get_name(item):match("([^/]+)$")
			table.insert(bufnames, bufname)
			table.insert(bufnumbers, item)
		end
	end

	if #bufnames == 0 then
		print("No other buffers to switch to")
		return
	end

	local bufnr = api.nvim_create_buf(false, false)

	api.nvim_buf_set_var(bufnr, "bufnumbers", bufnumbers)

	local width = 50
	local height = #bufnames
	local win_height = api.nvim_win_get_height(win_id)
	local row = math.ceil(win_height / 10) - math.ceil(height / 2)

	api.nvim_buf_set_lines(bufnr, 0, -1, false, bufnames)

	local winnr = api.nvim_open_win(bufnr, true, {
		relative = "win",
		win = win_id,
		width = width,
		height = height,
		col = math.ceil((api.nvim_win_get_width(win_id) - width) / 2),
		row = row,
		style = "minimal",
		border = "rounded",
	})

	api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<CR>",
		'<Cmd>lua require("better-window.selection").on_select(' .. bufnr .. ")<CR>",
		{ nowait = true, noremap = true, silent = true }
	)
	api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<Esc>",
		"<Cmd>lua vim.api.nvim_buf_delete(" .. bufnr .. ", { force = true })<CR>",
		{ nowait = true, noremap = true, silent = true }
	)

	api.nvim_buf_set_option(bufnr, "modifiable", false)

	-- Add this line after creating the window (nvim_open_win)
	api.nvim_win_set_option(winnr, "cursorline", true)
end

return M
