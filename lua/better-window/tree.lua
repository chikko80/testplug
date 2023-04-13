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

function PaneTree:removeNode(winId)
	local node = self:findNodeByWinId(winId)
	if not node or node == self.rootNode then
		error("Invalid node or root node cannot be removed")
	end

	-- Remove the node from its parent's children list
	node.parent:removeChild(node)

	-- If the parent node has only one child left, merge the remaining child with the parent
	if #node.parent.children == 1 then
		local remainingChild = node.parent.children[1]
		local grandParent = node.parent.parent

		-- If the parent is the root node, set the remaining child as the new root
		if node.parent == self.rootNode then
			self.rootNode = remainingChild
			remainingChild.parent = nil
		else
			-- Otherwise, replace the parent node with the remaining child in the grandparent's children list
			remainingChild.parent = grandParent
			for i, child in ipairs(grandParent.children) do
				if child == node.parent then
					grandParent.children[i] = remainingChild
					break
				end
			end
		end
	end
end

function PaneTree:splitVertical(winId, newWinId, bufnr)
	local node = self:findNodeByWinId(winId)
	if not node then
		error("Window not found in the tree")
	end

	local newEditorGroup = EditorGroup.new(newWinId)
	newEditorGroup:addEditor(bufnr)
	local newNode = Node.new(newEditorGroup, nil)

	if node.parent.isVertical == true then
		-- If the parent is already a vertical split type, insert the new node as a sibling after the active node
		local index = node:getIndexInParent()
		node.parent:insertChild(newNode, index + 1)
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

function PaneTree:splitHorizontal(winId, newWinId, bufnr)
	local node = self:findNodeByWinId(winId)
	if not node then
		error("Window not found in the tree")
	end

	local newEditorGroup = EditorGroup.new(newWinId)
	newEditorGroup:addEditor(bufnr)
	local newNode = Node.new(newEditorGroup, nil)

	if node.parent.isVertical == false then
		-- If the parent is already a horizontal split type, insert the new node as a sibling after the active node
		local index = node:getIndexInParent()
		node.parent:insertChild(newNode, index + 1)
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
		if not node.editorGroup.stack:isEmpty() then
			local buffers_str = indent .. "  Buffers: "
			for i, bufnr in ipairs(node.editorGroup.stack.items) do
				buffers_str = buffers_str .. bufnr
				if i < #node.editorGroup.stack.items then
					buffers_str = buffers_str .. ", "
				end
			end
			print(buffers_str)
		else
			print(indent .. "  No Buffers")
		end
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
