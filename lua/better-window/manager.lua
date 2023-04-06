local Stack = require("better-window.stack") -- Replace with the path to your Stack class

local EditorGroup = {}
EditorGroup.__index = EditorGroup

function EditorGroup.new()
	local self = setmetatable({}, EditorGroup)
	self.stacks = {}
	self.ordered_stacks = {} -- New table to maintain the order
	return self
end

function EditorGroup:createGroup(winid)
	local stack = Stack.new()
	self.stacks[winid] = stack
	table.insert(self.ordered_stacks, winid) -- Insert the winid into ordered_stacks
	return stack
end

function EditorGroup:setGroupOrder(open_windows)
	self.ordered_stacks = open_windows
end

function EditorGroup:getGroup(winid)
	return self.stacks[winid]
end

function EditorGroup:groupExists(win_id)
	return self.stacks[win_id] ~= nil
end

function EditorGroup:removeGroup(winid)
	for i, stored_winid in ipairs(self.ordered_stacks) do
		if stored_winid == winid then
			table.remove(self.ordered_stacks, i) -- Remove the winid from ordered_stacks
			break
		end
	end
	self.stacks[winid] = nil
end

function EditorGroup:addBufferToGroup(win_id, bufnr)
	local stack = self:getGroup(win_id)
	stack:addBufferToStack(bufnr)
end

function EditorGroup:moveEditorToAnotherGroup(src_winid, dst_winid, bufnr)
	local src_stack = self:getGroup(src_winid)
	local dst_stack = self:getGroup(dst_winid)

	if src_stack and dst_stack then
		src_stack:pop()
		dst_stack:addBufferToStack(bufnr)
	end
end

function EditorGroup:removeBufferFromGroup(group_id)
	local group = self:getGroup(group_id)
	group:pop()
end

function EditorGroup:getLatestBuffer(winid)
	local stack = self:getGroup(winid)
	if stack then
		return stack:getTop()
	else
		return nil
	end
end

function EditorGroup:removeGroupIfWindowRemoved(open_windows)
	for i = #self.ordered_stacks, 1, -1 do
		local item = self.ordered_stacks[i]
		local found = false

		-- Check if item exists in List B
		for _, bItem in ipairs(open_windows) do
			if bItem == item then
				found = true
				break
			end
		end

		-- Remove item from List A if not found in List B
		if not found then
			table.remove(self.ordered_stacks, i)
			self.stacks[item] = nil -- Remove the group from the stacks table
		end
	end
end

return EditorGroup
