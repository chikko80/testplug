local Node = require("better-window.node")
local EditorGroup = require("better-window.editor_group")

-- PaneTree class

local PaneTree = {}
PaneTree.__index = PaneTree

function PaneTree.new(win_id, win_nr)
	local self = setmetatable({}, PaneTree)

	-- create root node
	self.rootNode = Node.new(nil, nil)

	-- add init window to the tree
	local init_node = Node.new(EditorGroup.new(win_id, win_nr), self.rootNode)
	self.rootNode:addChild(init_node, true)
	return self
end

function PaneTree:isEmpty()
	return #self.rootNode.children == 0
end

function PaneTree:isLastGroup()
	return #self.rootNode.children == 1
end

function PaneTree:findNodeByWinNr(winNr)
	if #self.rootNode.children == 0 then
		return self.rootNode
	end

	return self:_findNodeByWinNr(self.rootNode, winNr)
end

function PaneTree:_findNodeByWinNr(node, winNr)
	if node.editorGroup then
		if node.editorGroup.win_nr == winNr then
			return node
		end
	end

	for _, child in ipairs(node.children) do
		local found = self:_findNodeByWinNr(child, winNr)
		if found then
			return found
		end
	end

	return nil
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
		return
	end
	self:_removeNode(node)
end

function PaneTree:_removeNode(node)
	local parent = node.parent

	-- Remove the node from its parent's children list
	parent:removeChild(node)

	-- If the parent node is the root node and has only one remaining child,
	-- we don't need to do anything else, because the root node should always have at least one child.
	if parent == self.rootNode and #parent.children == 1 then
		return
	end

	local grand_parent = parent.parent

	-- No child is left in parent, that happens if we removed the last editorgroup from a wrapper node
	if #parent.children == 0 then
		self:_removeNode(parent)

	-- Merge the remaining child with the grand_parent
	-- HACK: this is a bit hacky, we should probably insert/replace by index rather by appending as child
	elseif #parent.children == 1 then
		local remaining_sibling = parent.children[1]

		if remaining_sibling:isWrapper() then
			-- if the child is a wrapper, it has its own children, so we need to merge them into the grand_parent
			for _, child in ipairs(remaining_sibling.children) do
				grand_parent:addChild(child, grand_parent.isVertical)
			end
			grand_parent:removeChild(parent)
		else
			-- if the child is a single editorgroup, we just need to add it to the grand_parent
			grand_parent:addChild(remaining_sibling, grand_parent.isVertical)
			grand_parent:removeChild(parent)
		end
	else
		-- there are more than one child, so we don't, just remove the sibling from the group
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
		-- If the parent is horizontal and we split vertical, we need to build a new wrapper node and append the children to it
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
		-- If the parent is vertical and we split horizontal, we need to build a new wrapper node and append the children to it
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
		newParentNode:addChild(node, true) -- keep the vertical = true since we always consider a single pane like vertical pane
		newParentNode:addChild(newNode, true)
	end
end

function PaneTree:printTree()
	self:_printTreeRecursive(self.rootNode, 0)
end

function PaneTree:_printTreeRecursive(node, level)
	local indent = string.rep("  ", level)

	if node.editorGroup then
		print(
			indent .. "EditorGroup (win_id=" .. node.editorGroup.win_id .. " win_nr=" .. node.editorGroup.win_nr
				or nil .. ")",
			node.isVertical
		)
		if not node.editorGroup.stack:isEmpty() then
			local buffers_str = indent .. "  BuffersNrs: "
			local buffers_names_str = indent .. "  BuffersNames: "
			for i, editor in ipairs(node.editorGroup.stack.items) do
				buffers_str = buffers_str .. editor.buf_nr
				buffers_names_str = buffers_names_str .. editor.buf_name
				if i < #node.editorGroup.stack.items then
					buffers_str = buffers_str .. ", "
					buffers_names_str = buffers_names_str .. ", "
				end
			end
			print(buffers_str)
			print(buffers_names_str)
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
