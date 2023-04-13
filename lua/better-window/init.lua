-- better-window.nvim.lua



-- require("better-window.tabufline.lazyload")
local WindowManager = require("better-window.windows_manager")

local windows_manager

local function setup()
	-- Create commands
	-- vim.cmd("command! BetterWinMoveLeft lua require('better-window').move('l')")
	-- vim.cmd("command! BetterWinMoveRight lua require('better-window').move('r')")

	vim.cmd("command! BetterWinSplitVertical lua require('better-window').split('vsplit')")
	vim.cmd("command! BetterWinSplitHorizontal lua require('better-window').split('split')")
	vim.cmd("command! BetterWinRemoveFromGroup lua require('better-window').remove_from_group()")
	vim.cmd("command! BetterWinRemoveGroup lua require('better-window').remove_group()")

	vim.cmd("command! BetterWinSelection lua require('better-window.selection').show_popup()")

	vim.cmd([[
	     augroup LayoutTracker
	       autocmd!
	       autocmd BufEnter * lua require('better-window').add_to_group()
	       autocmd WinClosed * lua require('better-window').remove_group()
	     augroup END
   ]])

	-- init new grid with new group
	windows_manager = WindowManager.new()
end

-- editor operations
local function add_to_group()
	local winId = vim.api.nvim_get_current_win()
	local bufId = vim.api.nvim_get_current_buf()
	windows_manager:addEditor(winId, bufId)
end

local function remove_from_group()
	local winId = vim.api.nvim_get_current_win()
	local bufId = vim.api.nvim_get_current_buf()
	windows_manager:RemoveEditor(winId, bufId)
end

-- tree operations
local function split(command)
	windows_manager:split(command)
end

local function remove_group()
	local winId = vim.api.nvim_get_current_win()
    print('remove_group: '.. winId )
	windows_manager:RemoveGroup(winId)
end

local function test(dir)
	local winId = vim.api.nvim_get_current_win()
	print(windows_manager.paneTree:getClosestPane(winId, dir))
end

-- local function init()
--     -- if windows_manager.paneTree:isEmpty() then
--         windows_manager:split("vsplit")
--     -- end
-- end

--
-- local function update_layout(event)
-- 	-- get list of open buffers
-- 	local open_windows = utils.get_open_windows()
-- 	if open_windows == nil then
-- 		return
-- 	end
--
-- 	-- NOTE: WinNew and WinClosed are triggered too often in the background (probably by other plugins)
-- 	-- NOTE: Therefore we ignore the event it the layout didn't change
-- 	if event == "WNC" and #editor_group.ordered_stacks == #open_windows then
-- 		return
-- 	end
--
-- 	-- manage open buffers
-- 	for _, win_id in ipairs(open_windows) do
-- 		local bufnr = utils.get_open_buffer_per_win(win_id)
-- 		-- creaste group if not exists
-- 		if not editor_group:groupExists(win_id) then
-- 			editor_group:createGroup(win_id)
-- 			editor_group:addBufferToGroup(win_id, bufnr)
-- 		else
-- 			-- if group exists, add buffer to group
-- 			editor_group:addBufferToGroup(win_id, bufnr)
-- 		end
-- 	end
--
-- 	-- manage saved buffers
-- 	if #editor_group.ordered_stacks ~= #open_windows then
-- 		-- remove stack if we closed a window
-- 		editor_group:removeGroupIfWindowRemoved(open_windows)
-- 	end
-- 	-- always set order like on screen
-- 	editor_group:setGroupOrder(open_windows)
-- end
--
-- local function move(direction)
-- 	local current_window = vim.api.nvim_get_current_win()
-- 	local open_windows = utils.get_open_windows()
-- 	local index = utils.get_list_index(open_windows, current_window)
--
-- 	local new_win_id
--
-- 	if direction == "r" then
-- 		new_win_id = open_windows[index + 1]
-- 	elseif direction == "l" then
-- 		new_win_id = open_windows[index - 1]
-- 	end
--
-- 	if new_win_id == nil then
-- 		print("You can't move out of bounds")
-- 		return
-- 	end
--
-- 	local old_buf = vim.api.nvim_get_current_buf()
-- 	local old_win_id = vim.api.nvim_get_current_win()
-- 	local old_cursor_position = vim.api.nvim_win_get_cursor(old_win_id)
--
-- 	-- move buffer to new group
-- 	editor_group:moveEditorToAnotherGroup(old_win_id, new_win_id, old_buf)
--
-- 	-- replace the old buffer by latest stack after pop
-- 	local latest_buffer = editor_group:getLatestBuffer(old_win_id)
-- 	if latest_buffer == nil then
-- 		vim.api.nvim_win_close(old_win_id, true)
-- 	else
-- 		vim.api.nvim_win_set_buf(old_win_id, latest_buffer)
-- 	end
--
-- 	-- move buffer and set cursor position
-- 	vim.api.nvim_win_set_buf(new_win_id, old_buf)
-- 	vim.api.nvim_set_current_win(new_win_id)
-- 	vim.api.nvim_win_set_cursor(new_win_id, old_cursor_position)
-- 	-- center
-- 	vim.cmd("normal! zz")
-- end
--
-- local function remove_from_group(
-- 	local current_window = vim.api.nvim_get_current_win()
--
-- 	editor_group:removeBufferFromGroup(current_window)
-- 	local previous_buffer = editor_group:getLatestBuffer(current_window)
-- 	if previous_buffer == nil then
-- 		-- close winfo if no buffer left on stack
-- 		return vim.api.nvim_win_close(current_window, true)
-- 	else
-- 		vim.api.nvim_win_set_buf(current_window, previous_buffer)
-- 	end
-- end
--
local function debug()
	-- print("Layout " .. windows_manager.TreeLayout.rows, windows_manager.TreeLayout.columns)

	-- print(vim.inspect(windows_manager))
	print(vim.inspect(windows_manager.paneTree:printTree()))
	-- for row = 1, windows_manager.TreeLayout.rows do
	-- 	for col = 1, windows_manager.TreeLayout.columns do
	-- 		print("Stack - Row: " .. row .. " Col: " .. col .. vim.inspect(windows_manager.TreeLayout.grid[row][col]))
	-- 	end
	-- end
end

return {
	-- update_layout = update_layout,
	remove_group = remove_group,
	remove_from_group = remove_from_group,
	split = split,
	add_to_group = add_to_group,
	-- move = move,
	setup = setup,
	debug = debug,
	test = test,
	-- editor_group = editor_group,
}

--
-- bufremove.unshow_in_window(old_win_id)
