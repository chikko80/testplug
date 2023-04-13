-- Node class
local Node = {}
Node.__index = Node

function Node.new(editorGroup, parent)
	local self = setmetatable({}, Node)
	self.editorGroup = editorGroup
	self.parent = parent
	self.isVertical = true
	self.children = {}
	return self
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

	-- Return the next sibling
	return siblings[currentIndex + 1]
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

	-- Return the previous sibling
	return siblings[currentIndex - 1]
end

return Node
