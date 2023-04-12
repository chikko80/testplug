local GridLayout = require("better-window.grid")
local EditorGroup = require("better-window.editor_group")

local WindowManager = {}
WindowManager.__index = WindowManager

function WindowManager.new()
	local self = setmetatable({}, WindowManager)
	self.gridLayout = GridLayout.new()
	local initialWin = vim.api.nvim_get_current_win()
	local initialEditorGroup = EditorGroup.new(initialWin)
	self.gridLayout:addEditorGroup(initialEditorGroup, 1, 1)
	return self
end

function WindowManager:move(direction)
	local currentWinId = vim.api.nvim_get_current_win()
	local srcRow, srcCol = self.gridLayout:getPanePosition(currentWinId)

	local dstRow, dstCol
	if direction == "left" then
		dstRow, dstCol = srcRow, srcCol - 1
	elseif direction == "right" then
		dstRow, dstCol = srcRow, srcCol + 1
	elseif direction == "up" then
		dstRow, dstCol = srcRow - 1, srcCol
	elseif direction == "down" then
		dstRow, dstCol = srcRow + 1, srcCol
	end

	if dstRow >= 1 and dstRow <= self.gridLayout.rows and dstCol >= 1 and dstCol <= self.gridLayout.columns then
		local srcEditorGroup = self.gridLayout.grid[srcRow][srcCol]
		local dstEditorGroup = self.gridLayout.grid[dstRow][dstCol]

		local activeBuffer = srcEditorGroup.activeEditor
		srcEditorGroup:removeEditor(activeBuffer)
		dstEditorGroup:addEditor(activeBuffer)

		vim.api.nvim_set_current_win(dstEditorGroup.winnr)
	end
end

function WindowManager:remove_buffer()
	local currentWinId = vim.api.nvim_get_current_win()
	local row, col = self.gridLayout:getPanePosition(currentWinId)
	local editorGroup = self.gridLayout.grid[row][col]
	local activeBuffer = editorGroup.activeEditor
	editorGroup:removeEditor(activeBuffer)
end

function WindowManager:split(command)
	local currentWinId = vim.api.nvim_get_current_win()
	local newRow, newCol = self.gridLayout:splitPane(currentWinId, command)

	vim.api.nvim_command(command)

	local newWinId = vim.api.nvim_get_current_win()

	local newEditorGroup = EditorGroup.new(newWinId)
	self.gridLayout:addEditorGroup(newEditorGroup, newRow, newCol)
end

return WindowManager
