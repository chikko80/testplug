-- Node
local Node = {}
Node.__index = Node

function Node.new(editorGroup)
	local self = setmetatable({}, Node)
	self.children = {}
	self.editorGroup = editorGroup
	return self
end

return Node
