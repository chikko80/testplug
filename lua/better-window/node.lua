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

return Node
