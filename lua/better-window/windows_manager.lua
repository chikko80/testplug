local EditorGroup = require("better-window.editor_group")
local utils = require("better-window.utils")

local WindowManager = {}
WindowManager.__index = WindowManager

function WindowManager.new(tabId)
	local self = setmetatable({}, WindowManager)
	local currentWinId = vim.api.nvim_get_current_win()
	local currentWinNr = vim.fn.winnr()
	local start_group = EditorGroup.new(currentWinId, currentWinNr)
	self.editor_groups = {}
	self.editor_groups[currentWinId] = start_group
	self.tabId = tabId
	self.last_layout = utils.get_layout(tabId) -- single window on start
	return self
end

function WindowManager:updateDataAfterRestore(winNr, newWinId, buf_mapper)
	for old_win_id, editor_group in pairs(self.editor_groups) do
		if editor_group.win_nr == winNr then
			print(editor_group.win_nr, winNr, newWinId)
			-- update data
			editor_group:updateWinId(newWinId)
			editor_group:updateBufNrs(buf_mapper)

			-- upsert the editor group
			self.editor_groups[old_win_id] = nil
			self.editor_groups[newWinId] = editor_group
		end
	end
end

function WindowManager:updateWindowNumbers()
	for _, editor_group in pairs(self.editor_groups) do
		editor_group:updateWinNr()
	end
end

function WindowManager:getEditorGroup(winId)
	-- get the editor group by winId
	return self.editor_groups[winId]
end

function WindowManager:findByWindowNr(winNr)
	for _, editor_group in pairs(self.editor_groups) do
		if editor_group.win_nr == winNr then
			return editor_group
		end
	end
end

function WindowManager:addEditor(winId, bufId)
	local editor_group = self.editor_groups[winId]

	if not editor_group then
		print("No editor group found")
		return
	end

	local bufname = vim.api.nvim_buf_get_name(bufId)
	if bufname and not bufname:match("^NvimTree") then
		return
	end

	editor_group:addEditor(bufId)
end

function WindowManager:RemoveEditor(winId, bufId)
	local editor_group = self.editor_groups[winId]
	if not editor_group then
		return
	end
	editor_group:removeEditor(bufId)
end

function WindowManager:isLastGroup()
	return #self.editor_groups == 1
end

function WindowManager:RemoveGroup(winId)
	local editor_group = self.editor_groups[winId]
	if not editor_group then
		return
	end

	if self:isLastGroup() then
		print("Can't remove last group")
		return
	end

	-- remove the editor group
	self.editor_groups[winId] = nil
end

function WindowManager:move_into_editor_group(direction)
	print("moving")
	local current_win_id = vim.api.nvim_get_current_win()
	local current_buf_id = vim.api.nvim_get_current_buf()

	local old_cursor_position = vim.api.nvim_win_get_cursor(current_win_id)

	local current_editor_group = self.editor_groups[current_win_id]
	if not current_editor_group then
		return
	end

	local target_win = utils.find_closest_pane(utils.get_layout(self.tabId), current_win_id, direction)
	local target_group = self.editor_groups[target_win]
	if not target_group then
		return
	end

	-- Move the editor from the current group to the target group
	current_editor_group:removeEditor(current_buf_id)
	target_group:addEditor(current_buf_id)

	-- restore cursor position
	target_group:restoreCursor(old_cursor_position)

	-- center
	vim.cmd("normal! zz")
end

function WindowManager:split(command)
	local old_buf_id = vim.api.nvim_get_current_buf()

	vim.api.nvim_command(command)

	local newWinId = vim.api.nvim_get_current_win()
	local newWinNr = vim.fn.winnr()
	local new_group = EditorGroup.new(newWinId, newWinNr)
	new_group:addEditor(old_buf_id)

	self.editor_groups[newWinId] = new_group
end

return WindowManager
