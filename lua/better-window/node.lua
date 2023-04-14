-- Node class
local Node = {}
Node.__index = Node

local function generateUniqueId()
	-- Generate a random 10-digit number
	return math.random(100000000000000000, 999999999999999999)
end

function Node.new(editorGroup, parent)
	local self = setmetatable({}, Node)
	self.editorGroup = editorGroup
	self.parent = parent
	self.isVertical = true
	self.children = {}
	self.id = generateUniqueId()
	return self
end

function Node:isWrapper()
	return #self.children > 0 and self.editorGroup == nil
end

function Node:addChild(childNode, isVertical)
	childNode.parent = self
	childNode.isVertical = isVertical
	table.insert(self.children, childNode)
end

function Node:removeChild(childNode)
	for i, child in ipairs(self.children) do
		if child == childNode then
			table.remove(self.children, i)
			break
		end
	end
end

function Node:getIndexInParent()
	for i, child in ipairs(self.parent.children) do
		if child == self then
			return i
		end
	end
	return nil
end

function Node:insertChild(childNode, index)
	childNode.parent = self
	childNode.isVertical = childNode.isVertical or false
	table.insert(self.children, index, childNode)
end

function Node:getNextSibling()
	-- If the node doesn't have a parent, it has no siblings
	if not self.parent then
		return nil
	end

	local siblings = self.parent.children
	local currentIndex = self:getIndexInParent()

	-- If the current node is the last child, it has no next sibling
	if currentIndex == #siblings then
		return nil
	end

	-- Get the next sibling and find the first non-wrapper node
	local nextSibling = siblings[currentIndex + 1]
	while nextSibling:isWrapper() do
		nextSibling = nextSibling.children[1]
	end

	return nextSibling
end

function Node:getPrevSibling()
	-- If the node doesn't have a parent, it has no siblings
	if not self.parent then
		return nil
	end

	local siblings = self.parent.children
	local currentIndex = self:getIndexInParent()

	-- If the current node is the first child, it has no previous sibling
	if currentIndex == 1 then
		return nil
	end

	-- Get the previous sibling and find the last non-wrapper node
	local prevSibling = siblings[currentIndex - 1]
	while prevSibling:isWrapper() do
		prevSibling = prevSibling.children[#prevSibling.children]
	end

	return prevSibling
end

return Node
