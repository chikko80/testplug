local Stack = require("better-window.stack") -- Replace with the path to your Stack class

-- EditorGroup
local EditorGroup = {}
EditorGroup.__index = EditorGroup

function EditorGroup.new(win_id)
	local self = setmetatable({}, EditorGroup)
	self.win_id = win_id
	self.activeEditor = nil
	self.stack = Stack.new() -- Use Stack to manage editors within the group
	return self
end

function EditorGroup:addEditor(bufnr)
	self.stack:addEditorToStack(bufnr)
	self:setActiveEditor(bufnr)
end

function EditorGroup:removeEditor(bufnr)
	self.stack:removeEditorFromStack(bufnr)

	local peek_stack = self.stack:peek()
	if not peek_stack then
		return true -- return true if this was the last editor in the group
	end

	if bufnr == self.activeEditor then
		self:setActiveEditor(peek_stack) -- set active editor to the top of the stack
	end
	return false
end

function EditorGroup:setActiveEditor(bufnr)
	self.activeEditor = bufnr
	if bufnr then
		vim.api.nvim_win_set_buf(self.win_id, bufnr)
	end
end

return EditorGroup
