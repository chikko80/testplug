local Node = require("better-window.node")
local EditorGroup = require("better-window.editor_group")

-- PaneTree class

local PaneTree = {}
PaneTree.__index = PaneTree

function PaneTree.new(win_id)
	local self = setmetatable({}, PaneTree)

	-- create root node
	self.rootNode = Node.new(nil, nil)

	-- add init window to the tree
	local init_node = Node.new(EditorGroup.new(win_id), self.rootNode)
	self.rootNode:addChild(init_node, true)
	return self
end

function PaneTree:isEmpty()
	return #self.rootNode.children == 0
end

function PaneTree:findNodeByWinId(winId)
	if #self.rootNode.children == 0 then
		return self.rootNode
	end

	return self:_findNodeByWinId(self.rootNode, winId)
end

function PaneTree:_findNodeByWinId(node, winId)
	if node.editorGroup then
		if node.editorGroup.win_id == winId then
			return node
		end
	end

	for _, child in ipairs(node.children) do
		local found = self:_findNodeByWinId(child, winId)
		if found then
			return found
		end
	end

	return nil
end

function PaneTree:splitVertical(winId, newWinId)
	local node = self:findNodeByWinId(winId)
	if not node then
		error("Window not found in the tree")
	end

	local newEditorGroup = EditorGroup.new(newWinId)
	local newNode = Node.new(newEditorGroup, nil)

	if node.parent.isVertical == true then
		-- If the parent is already a vertical split type, just add the new node as a sibling
		node.parent:addChild(newNode, true)
	else
		local newParentNode = Node.new(nil, node.parent)
		newParentNode.isVertical = true

		-- Replace the original node in its parent's children list with the newParentNode
		for i, child in ipairs(node.parent.children) do
			if child == node then
				node.parent.children[i] = newParentNode
				break
			end
		end

		-- Add the original node and the new Node as child nodes to the newParentNode
		newParentNode:addChild(node, true)
		newParentNode:addChild(newNode, true)
	end
end

function PaneTree:splitHorizontal(winId, newWinId)
	local node = self:findNodeByWinId(winId)
	if not node then
		error("Window not found in the tree")
	end

	local newEditorGroup = EditorGroup.new(newWinId)
	local newNode = Node.new(newEditorGroup, nil)


	if node.parent.isVertical == false then
		-- If the parent is already a horizontal split type, just add the new node as a sibling
		node.parent:addChild(newNode, false)
	else
		local newParentNode = Node.new(nil, node.parent)
		newParentNode.isVertical = false

		-- Replace the original node in its parent's children list with the newParentNode
		for i, child in ipairs(node.parent.children) do
			if child == node then
				node.parent.children[i] = newParentNode
				break
			end
		end

		-- Add the original node and the new Node as child nodes to the newParentNode
		newParentNode:addChild(node, false)
		newParentNode:addChild(newNode, false)
	end

end

function PaneTree:printTree()
	self:_printTreeRecursive(self.rootNode, 0)
end

function PaneTree:_printTreeRecursive(node, level)
	local indent = string.rep("  ", level)

	if node.editorGroup then
		print(indent .. "EditorGroup (win_id=" .. node.editorGroup.win_id .. ")")
	elseif node == self.rootNode then
		print(indent .. "RootNode")
	else
		print(indent .. "Node")
		if node.isVertical == nil then
			print(indent .. "  Split Type: None")
		elseif node.isVertical then
			print(indent .. "  Split Type: Vertical")
		else
			print(indent .. "  Split Type: Horizontal")
		end
	end

	if #node.children > 0 then
		print(indent .. "{")
		for _, child in ipairs(node.children) do
			self:_printTreeRecursive(child, level + 1)
		end
		print(indent .. "}")
	end
end

return PaneTree
