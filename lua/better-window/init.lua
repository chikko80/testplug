-- better-window.nvim.lua

local utils = require("better-window.utils")
local EditorGroup = require("better-window.manager")

local editor_group = EditorGroup.new()

local function debug()
	for _, win_id in pairs(editor_group.ordered_stacks) do
		print("Window ID:", win_id)
		print("Stack contents:", vim.inspect(editor_group.stacks[win_id]))
	end
end

local function setup()
	vim.cmd([[
      augroup LayoutTracker
        autocmd!
        autocmd WinNew,WinClosed * lua require('better-window').update_layout("WNC")
        autocmd VimEnter * lua require('better-window').update_layout()
        autocmd BufWinEnter * lua require('better-window').update_layout()
      augroup END
    ]])
	-- Create commands
	vim.cmd("command! MoveBufferLeft lua require('better-window').move('l')")
	vim.cmd("command! MoveBufferRight lua require('better-window').move('r')")
	vim.cmd("command! RemoveBufferFromStack lua require('better-window').remove_buffer()")
end

local function move(direction)
	local current_window = vim.api.nvim_get_current_win()
	local open_windows = utils.get_open_windows()
	local index = utils.get_list_index(open_windows, current_window)

	local new_win_id

	if direction == "r" then
		new_win_id = open_windows[index + 1]
	elseif direction == "l" then
		new_win_id = open_windows[index - 1]
	end

	if new_win_id == nil then
		return
	end

	local old_buf = vim.api.nvim_get_current_buf()
	local old_win_id = vim.api.nvim_get_current_win()
	local old_cursor_position = vim.api.nvim_win_get_cursor(old_win_id)

	-- move buffer to new group
	editor_group:moveEditorToAnotherGroup(old_win_id, new_win_id, old_buf)

	-- replace the old buffer by latest stack after pop
	local latest_buffer = editor_group:getLatestBuffer(old_win_id)
	if latest_buffer == nil then
		vim.api.nvim_win_close(old_win_id, true)
	else
		vim.api.nvim_win_set_buf(old_win_id, latest_buffer)
	end

	-- move buffer and set cursor position
	vim.api.nvim_win_set_buf(new_win_id, old_buf)
	vim.api.nvim_set_current_win(new_win_id)
	vim.api.nvim_win_set_cursor(new_win_id, old_cursor_position)
	-- center
	vim.cmd("normal! zz")
end

local function remove_buffer()
	local current_window = vim.api.nvim_get_current_win()
	local current_buffer = vim.api.nvim_get_current_buf()

	editor_group:removeBufferFromGroup(current_window, current_buffer)
	local previous_buffer = editor_group:getLatestBuffer(current_window)
	if previous_buffer == nil then
		-- close winfo if no buffer left on stack
		return vim.api.nvim_win_close(current_window, true)
	else
		vim.api.nvim_win_set_buf(current_window, previous_buffer)
	end
end

local function update_layout(event)
	-- get list of open buffers
	local open_windows = utils.get_open_windows()
	if open_windows == nil then
		return
	end

	-- NOTE: WinNew and WinClosed are triggered too often in the background (probably by other plugins)
    -- NOTE: Therefore we ignore the event it the layout didn't change
	if event == "WNC" and #editor_group.ordered_stacks == #open_windows then
		return
	end

	-- manage open buffers
	for _, win_id in ipairs(open_windows) do
		local bufnr = utils.get_open_buffer_per_win(win_id)
		-- creaste group if not exists
		if not editor_group:groupExists(win_id) then
			editor_group:createGroup(win_id)
			editor_group:addBufferToGroup(win_id, bufnr)
		else
			-- if group exists, add buffer to group
			editor_group:addBufferToGroup(win_id, bufnr)
		end
	end

	-- manage saved buffers
	-- TODO: remove groups if not in current tab
	-- TODO: sort
	if #editor_group.ordered_stacks ~= #open_windows then
		editor_group:removeGroupIfWindowRemoved(open_windows)
	end
	editor_group:setGroupOrder(open_windows)
	debug()
end

return {
	update_layout = update_layout,
	remove_buffer = remove_buffer,
	move = move,
	setup = setup,
	debug = debug,
}

--
-- bufremove.unshow_in_window(old_win_id)