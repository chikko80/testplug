local PaneTree = require("better-window.tree")
local utils = require("better-window.utils")

local WindowManager = {}
WindowManager.__index = WindowManager
WindowManager.last_layout = nil

function WindowManager.new()
	local self = setmetatable({}, WindowManager)

	local currentWinId = vim.api.nvim_get_current_win()
	self.paneTree = PaneTree.new(currentWinId)
	self.last_layout = utils.get_layout() -- single window on start
	return self
end

function WindowManager:addEditor(winId, bufId)
	local node = self.paneTree:findNodeByWinId(winId)
	if not node then
		return
	end
	node.editorGroup:addEditor(bufId)
end

function WindowManager:RemoveEditor(winId, bufId)
	local node = self.paneTree:findNodeByWinId(winId)
	if not node then
		return
	end

	node.editorGroup:removeEditor(bufId)
end

function WindowManager:RemoveGroup(winId)
	local node = self.paneTree:findNodeByWinId(winId)
	-- check if node in tree
	if not node then
		return
	end

	-- if we are on level 0 and its a vertical split (1x1)
	if self.paneTree:isLastGroup() and self.paneTree.rootNode.children[1].isVertical then
		print("Can't remove last group")
		return
	end

	self.paneTree:removeNode(winId)
end

function WindowManager:move_into_editor_group(direction)
	local current_win_id = vim.api.nvim_get_current_win()
	local current_buf_id = vim.api.nvim_get_current_buf()

	local old_cursor_position = vim.api.nvim_win_get_cursor(current_win_id)

	local current_node = self.paneTree:findNodeByWinId(current_win_id)
	if not current_node or not current_node.parent then
		return
	end

	local target_win = utils.find_closest_pane(utils.get_layout(), current_win_id, direction)
	local target_node = self.paneTree:findNodeByWinId(target_win)
	if not target_node then
		return
	end

	-- Move the editor from the current group to the target group
	current_node.editorGroup:removeEditor(current_buf_id)
	target_node.editorGroup:addEditor(current_buf_id)

	-- restore cursor position
	target_node.editorGroup:restoreCursor(old_cursor_position)

	-- center
	vim.cmd("normal! zz")
end

function WindowManager:split(command)
	local old_buf_id = vim.api.nvim_get_current_buf()
	local old_win_id = vim.api.nvim_get_current_win()
	vim.api.nvim_command(command)
	local newWinId = vim.api.nvim_get_current_win()
	-- print(newWinId)

	if command == "vsplit" then
		self.paneTree:splitVertical(old_win_id, newWinId, old_buf_id)
	elseif command == "split" then
		self.paneTree:splitHorizontal(old_win_id, newWinId, old_buf_id)
	end
end

return WindowManager
