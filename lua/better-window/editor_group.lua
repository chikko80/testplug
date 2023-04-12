local Stack = require("better-window.stack") -- Replace with the path to your Stack class


-- EditorGroup
local EditorGroup = {}
EditorGroup.__index = EditorGroup

function EditorGroup.new(winnr)
	local self = setmetatable({}, EditorGroup)
	self.winnr = winnr
	self.activeEditor = nil
	self.stack = Stack.new() -- Use Stack to manage editors within the group
	return self
end

function EditorGroup:addEditor(bufnr)
	self.stack:addEditorToStack(bufnr)
	self:setActiveEditor(bufnr)
end

function EditorGroup:removeEditor(bufnr)
	local index = self.stack:indexOf(bufnr)
	if index then
		table.remove(self.stack.items, index)
	end

	if bufnr == self.activebufnr then
		self.stack:pop() -- remove from stack
		self:setActiveEditor(self.stack:peek()) -- set active editor to the top of the stack
	end
end

function EditorGroup:setActiveEditor(bufnr)
	self.activeEditor = bufnr
	if bufnr then
		vim.api.nvim_win_set_buf(self.winnr, bufnr)
	end
end

return EditorGroup
