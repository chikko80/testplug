local Editor = require("better-window.editor")

-- Stack class
local Stack = {}
Stack.__index = Stack

--- Changed to use the Editor class
--- Still dependend on bufnr

-- Create a new stack
function Stack.new()
	local self = setmetatable({}, Stack)
	self.items = {}
	return self
end

-- Find the index of an item in the stack
function Stack:indexOf(buf_nr)
	for i, editor in ipairs(self.items) do
		if editor.buf_nr == buf_nr then
			return i
		end
	end
	return nil
end

-- Peek at the top item on the stack without removing it
function Stack:peek()
	if self:isEmpty() then
		return nil
	else
		return self.items[#self.items].buf_nr
	end
end

-- Add a buffer to the stack (modified)
function Stack:addEditorToStack(bufnr)
	local buf_name = vim.api.nvim_buf_get_name(bufnr)
	local index = self:indexOf(bufnr)

	local new_editor = Editor.new(bufnr, buf_name)

	if index then
		-- If the buffer is already in the stack, move it to the top
		table.remove(self.items, index)
		table.insert(self.items, new_editor)
	else
		-- If the buffer is not in the stack, add it as usual
		table.insert(self.items, new_editor)
	end
end

function Stack:removeEditorFromStack(bufnr)
	local index = self:indexOf(bufnr)
	if index then
		table.remove(self.items, index)
	end
end

-- Check if the stack is empty
function Stack:isEmpty()
	return #self.items == 0
end

-- Add a new print method to the Stack metatable
function Stack:print()
	local output = "Stack contents: "
	for i, item in ipairs(self.items) do
		local bufname = vim.api.nvim_buf_get_name(item):match("([^/]+)$")
		output = output .. bufname
		if i < #self.items then
			output = output .. ", "
		end
	end
end

return Stack
