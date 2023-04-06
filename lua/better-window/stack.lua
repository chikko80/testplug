-- Stack class

local Stack = {}
Stack.__index = Stack

-- Create a new stack
function Stack.new()
	local self = setmetatable({}, Stack)
	self.items = {}
	return self
end

-- Find the index of an item in the stack
function Stack:indexOf(item)
	for i, v in ipairs(self.items) do
		if v == item then
			return i
		end
	end
	return nil
end

function Stack:getTop()
	if self:isEmpty() then
		return nil
	else
		return self.items[#self.items]
	end
end

-- Add a buffer to the stack (modified)
function Stack:addBufferToStack(bufnr)
	local index = self:indexOf(bufnr)

	if index then
		-- If the buffer is already in the stack, move it to the top
		table.remove(self.items, index)
		table.insert(self.items, bufnr)
	else
		-- If the buffer is not in the stack, add it as usual
		self:push(bufnr)
	end
end

-- Push an item onto the stack
function Stack:push(item)
	table.insert(self.items, item)
end

-- Pop an item from the stack
function Stack:pop()
	if self:isEmpty() then
		error("Stack is empty")
	else
		return table.remove(self.items)
	end
end

-- Check if the stack is empty
function Stack:isEmpty()
	return #self.items == 0
end

-- Get the size of the stack
function Stack:size()
	return #self.items
end

-- Peek at the top item on the stack without removing it
function Stack:peek()
	if self:isEmpty() then
		error("Stack is empty")
	else
		return self.items[#self.items]
	end
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
