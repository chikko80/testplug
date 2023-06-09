require("better-window.winbar.autocommands")
local SharedState

-- TODO: seems like there is a timing issue on restoring, sometimes it doesn't work (buffer doesn't get updated)
-- TODO: check if tabs work

local function setup()
	-- Create commands
	vim.cmd("command! BetterWinMoveLeft lua require('better-window').move('left')")
	vim.cmd("command! BetterWinMoveRight lua require('better-window').move('right')")
	vim.cmd("command! BetterWinMoveUp lua require('better-window').move('up')")
	vim.cmd("command! BetterWinMoveDown lua require('better-window').move('down')")

	vim.cmd("command! BetterWinSplitVertical lua require('better-window').split('vsplit')")
	vim.cmd("command! BetterWinSplitHorizontal lua require('better-window').split('split')")
	vim.cmd("command! BetterWinRemoveFromGroup lua require('better-window').remove_from_group()")
	vim.cmd("command! BetterWinRemoveGroup lua require('better-window').remove_group()")
	vim.cmd("command! BetterWinSelection lua require('better-window.selection').show_popup()")

	vim.cmd([[
    augroup BetterWindowAutocommands
        autocmd!

        autocmd TabNew * lua require('better-window').add_tab()
        autocmd TabClosed * lua require('better-window').remove_tab()

        autocmd BufEnter * lua require('better-window').add_to_group()
        autocmd WinClosed * lua vim.schedule_wrap(require('better-window').remove_group)()

"
        autocmd VimLeavePre * lua require("better-window.session").save()
        autocmd SessionLoadPost * lua vim.schedule_wrap(require('better-window.session').restore)()
        
    augroup END
    ]])

	-- init new grid with new group
	SharedState = require("better-window.state")
end

local function add_tab()
	local tabId = vim.api.nvim_get_current_tabpage()
	SharedState.get_tab_manager():add_tab(tabId)
end

local function remove_tab()
	SharedState.get_tab_manager():remove_tab()
end

local function move(direction)
	local tabId = vim.api.nvim_get_current_tabpage()
	SharedState.get_tab_manager():move_into_editor_group(tabId, direction)
	SharedState.get_tab_manager():update_window_numbers(tabId)
end

-- editor operations
local function add_to_group()
	local tabId = vim.api.nvim_get_current_tabpage()
	SharedState.get_tab_manager():add_to_group(tabId)
	SharedState.get_tab_manager():update_window_numbers(tabId)
end

local function remove_from_group()
	local tabId = vim.api.nvim_get_current_tabpage()
	SharedState.get_tab_manager():remove_from_group(tabId)
	SharedState.get_tab_manager():update_window_numbers(tabId)
end

-- tree operations
local function split(command)
	local tabId = vim.api.nvim_get_current_tabpage()
	SharedState.get_tab_manager():split(tabId, command)
	SharedState.get_tab_manager():update_window_numbers(tabId)
end

local function remove_group()
	local tabId = vim.api.nvim_get_current_tabpage()
	SharedState.get_tab_manager():remove_group(tabId)
	SharedState.get_tab_manager():update_window_numbers(tabId)
end

local function debug()
	print(vim.inspect(SharedState.get_tab_manager()))
end

local function get_windows_manager()
	local tabId = vim.api.nvim_get_current_tabpage()
	return SharedState.get_tab_manager():get_windows_manager(tabId)
end

local function pretty_print()
	local tabId = vim.api.nvim_get_current_tabpage()
	SharedState.get_tab_manager():prettyPrint(tabId)
end

return {
	add_tab = add_tab,
	remove_tab = remove_tab,
	remove_group = remove_group,
	remove_from_group = remove_from_group,
	split = split,
	add_to_group = add_to_group,
	move = move,
	setup = setup,
	debug = debug,
	get_windows_manager = get_windows_manager,
	pretty_print = pretty_print,
}
