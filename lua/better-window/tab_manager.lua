local WindowManager = require("better-window.windows_manager")
local utils = require("better-window.utils")

local TabManager = {}
TabManager.__index = TabManager

function TabManager.new()
	local self = setmetatable({}, TabManager)
	self.tabs = utils.get_tabs()
	self.windows_manager = {} -- Initialize windows_manager

	local currentTabId = vim.api.nvim_get_current_tabpage()
	self.windows_manager[currentTabId] = WindowManager.new(currentTabId)

	return self
end

function TabManager:update_window_numbers(tabId)
	if not self.windows_manager[tabId] then
		return
	end

	self.windows_manager[tabId]:updateWindowNumbers()
end

function TabManager:update_window_ids(tabId)
	if not self.windows_manager[tabId] then
		return
	end

	self.windows_manager[tabId]:updateWindowIds()
end

function TabManager:add_tab(tabId)
	self.windows_manager[tabId] = WindowManager.new(tabId)

	-- update tabs
	self.tabs = utils.get_tabs()
end

function TabManager:remove_tab()
	local new_tab_list = utils.get_tabs()

	-- detect the removed tab/s
	for _, tabId in ipairs(utils.get_list_diff(self.tabs, new_tab_list)) do
		self.windows_manager[tabId] = nil
	end

	-- update tabs
	self.tabs = new_tab_list
end

function TabManager:move_into_editor_group(tabId, direction)
	if not self.windows_manager[tabId] then
		return
	end

	self.windows_manager[tabId]:move_into_editor_group(direction)
end

-- editor operations
function TabManager:add_to_group(tabId)
	if not self.windows_manager[tabId] then
		return
	end

	local winId, bufId = utils.get_win_and_buf_id()
	self.windows_manager[tabId]:addEditor(winId, bufId)
end

function TabManager:remove_from_group(tabId)
	if not self.windows_manager[tabId] then
		return
	end

	local winId, bufId = utils.get_win_and_buf_id()
	self.windows_manager[tabId]:RemoveEditor(winId, bufId)
end

-- tree operations
function TabManager:split(tabId, command)
	if not self.windows_manager[tabId] then
		return
	end

	self.windows_manager[tabId]:split(command)

	-- save new layout
	self.windows_manager[tabId].last_layout = utils.get_layout(tabId)
end

function TabManager:remove_group(tabId)
	if not self.windows_manager[tabId] then
		return
	end

	local new_layout = utils.get_layout(tabId)
	-- if user didn't change layout, do nothing
	if #self.windows_manager[tabId].last_layout == #new_layout then
		return
	end

	-- remove everything that is not in the new layout
	for _, value in ipairs(utils.get_list_diff(self.windows_manager[tabId].last_layout, new_layout)) do
		self.windows_manager[tabId]:RemoveGroup(value)
	end

	-- save new layout
	self.windows_manager[tabId].last_layout = new_layout
end

function TabManager:debug(tabId)
	if not self.windows_manager[tabId] then
		return
	end
	print(vim.inspect(self.windows_manager[tabId].editor_groups))
end

function TabManager:get_windows_manager(tabId)
	if not self.windows_manager[tabId] then
		return
	end
	return self.windows_manager[tabId]
end

return TabManager
