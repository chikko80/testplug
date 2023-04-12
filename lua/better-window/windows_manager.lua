local TreeLayout = require("better-window.tree")

local WindowManager = {}
WindowManager.__index = WindowManager

function WindowManager.new()
	local self = setmetatable({}, WindowManager)
	self.treeLayout = TreeLayout.new()
	return self
end

function WindowManager:move(direction)
	local currentWinId = vim.api.nvim_get_current_win()
	local currentNode = self.treeLayout:getPaneNode(currentWinId)

	local dstNode
	if direction == "left" then
		dstNode = currentNode.parent.children[1]
	elseif direction == "right" then
		dstNode = currentNode.parent.children[2]
	elseif direction == "up" then
		dstNode = currentNode.parent.children[1]
	elseif direction == "down" then
		dstNode = currentNode.parent.children[2]
	end

	if dstNode and dstNode.editorGroup then
		local activeBuffer = currentNode.editorGroup.activeEditor
		currentNode.editorGroup:removeEditor(activeBuffer)
		dstNode.editorGroup:addEditor(activeBuffer)

		vim.api.nvim_set_current_win(dstNode.editorGroup.winnr)
	end
end

function WindowManager:add_buffer(winnr, bufnr)
	local node = self.treeLayout:getPaneNode(winnr)
	if node and node.editorGroup then
		node.editorGroup:addEditor(bufnr)
	end
end

function WindowManager:remove_buffer()
	local currentWinId = vim.api.nvim_get_current_win()
	local node = self.treeLayout:getPaneNode(currentWinId)
	if node and node.editorGroup then
		local activeBuffer = node.editorGroup.activeEditor
		node.editorGroup:removeEditor(activeBuffer)
	end
end

function WindowManager:split(command)
	local currentBufId = vim.api.nvim_get_current_buf()
	local currentWinId = vim.api.nvim_get_current_win()
	local currentNode = self.treeLayout:getPaneNode(currentWinId)

	vim.api.nvim_command(command)

	local newWinId = vim.api.nvim_get_current_win()

	local newNode = self.treeLayout:splitPane(currentNode, command)
	newNode.editorGroup.winnr = newWinId
	newNode.editorGroup:addEditor(currentBufId)
end

return WindowManager
