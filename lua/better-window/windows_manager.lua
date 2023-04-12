local Node = require("better-window.node")
local EditorGroup = require("better-window.editor_group")
local PaneTree = require("better-window.tree")

local WindowManager = {}
WindowManager.__index = WindowManager

function WindowManager.new()
	local self = setmetatable({}, WindowManager)

	local currentWinId = vim.api.nvim_get_current_win()
	self.paneTree = PaneTree.new(currentWinId)
	return self
end

function WindowManager:split(command)
	local old_win_id = vim.api.nvim_get_current_win()
	vim.api.nvim_command(command)
	local newWinId = vim.api.nvim_get_current_win()

	if command == "vsplit" then
		self.paneTree:splitVertical(old_win_id, newWinId)
    elseif command == "split" then
        self.paneTree:splitHorizontal(old_win_id, newWinId)
	end
end

return WindowManager

-- local currentWinId = vim.api.nvim_get_current_win()
-- local currentNode = self.treeLayout:getPaneNode(currentWinId)
-- local newNode = self.treeLayout:splitPane(currentNode, command)
-- newNode.editorGroup.winnr = newWinId
-- newNode.editorGroup:addEditor(currentBufId)
