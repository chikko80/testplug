-- better-window.nvim.lua
-- require("better-window.tabufline.lazyload")
local WindowManager = require("better-window.windows_manager")
local utils = require("better-window.utils")

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
        autocmd BufDelete * lua require('better-window').remove_group()
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

	-- save new layout
	windows_manager.last_layout = utils.get_layout()
	windows_manager.paneTree:printTree()
end

local function remove_group()
	local new_layout = utils.get_layout()
    -- print(#windows_manager.last_layout , #new_layout)
	-- if user didn't change layout, do nothing
	if #windows_manager.last_layout == #new_layout then
		return
	end
	-- local winId = vim.api.nvim_get_current_win()

	-- remove everything that is not in the new layout
	for _, value in ipairs(utils.get_layout_diff(windows_manager.last_layout, new_layout)) do
		windows_manager:RemoveGroup(value)
	end

	-- save new layout
	windows_manager.last_layout = new_layout
	windows_manager.paneTree:printTree()
end

local function test(dir)
	local winId = vim.api.nvim_get_current_win()
	print(windows_manager.paneTree:getClosestPane(winId, dir))
end

local function debug()
	-- print(vim.inspect(windows_manager))
	windows_manager.paneTree:printTree()
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
