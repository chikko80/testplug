local Node = require("better-window.node")
local EditorGroup = require("better-window.editor_group")
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

	local last_editor_in_group = node.editorGroup:removeEditor(bufId)
	if last_editor_in_group then
		vim.api.nvim_win_close(winId, true)
	end
end

function WindowManager:RemoveGroup(winId)
	local node = self.paneTree:findNodeByWinId(winId)
	-- check if node in tree
	if not node then
		return
	end

    -- if last children and its a vertical split so a single col with a single row
	if self.paneTree:isLastGroup() and self.paneTree.rootNode.children[1].isVertical then
		print("Can't remove last group")
		return
	end

	self.paneTree:removeNode(winId)
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

-- local currentWinId = vim.api.nvim_get_current_win()
-- local currentNode = self.treeLayout:getPaneNode(currentWinId)
-- local newNode = self.treeLayout:splitPane(currentNode, command)
-- newNode.editorGroup.winnr = newWinId
-- newNode.editorGroup:addEditor(currentBufId)
