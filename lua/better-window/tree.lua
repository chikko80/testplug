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

function PaneTree:isLastGroup()
	return #self.rootNode.children == 1
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

	-- Remove the node from its parent's children list
	node.parent:removeChild(node)

	local parent = node.parent

	-- If the parent node is the root node and has only one remaining child,
	-- we don't need to do anything else, because the root node should always have at least one child.
	if parent == self.rootNode and #parent.children == 1 then
		return
	end

	-- If the parent node is not the root node and has only one remaining child,
	-- remove the parent node and attach the remaining child to its grandparent.
	if self.rootNode and #parent.children == 1 then
		local remainingChild = parent.children[1]
		local grandParent = parent.parent

		-- Remove the parent from the grandparent's children list
		for i, child in ipairs(grandParent.children) do
			if child == parent then
				table.remove(grandParent.children, i)
				break
			end
		end

		-- Attach the remaining child to the grandparent
		remainingChild.parent = grandParent
		table.insert(grandParent.children, remainingChild)

		-- Copy the layout and size properties from the parent to the remaining child
		remainingChild.layout = parent.layout
		remainingChild.size = parent.size
	end

	-- If the parent node has no remaining children, recursively remove the parent node
	if #parent.children == 0 then
		self:removeNode(parent.winId)
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


function PaneTree:findClosestNodeInDirection(root, current, direction)
  if not current or not current.parent then
    return nil
  end

  local function findSiblingInDirection(node, dir)
    local parent = node.parent
    if not parent or not parent.children then
      return nil
    end

    local currentIndex = node:getIndexInParent()

    if dir == "left" or dir == "up" then
      return parent.children[currentIndex - 1]
    elseif dir == "right" or dir == "down" then
      return parent.children[currentIndex + 1]
    end

    return nil
  end

  local sibling = findSiblingInDirection(current, direction)

  if sibling then
    -- Navigate deeper into the sibling based on the direction
    while sibling.children and #sibling.children > 0 do
      if direction == "left" or direction == "right" then
        sibling = sibling.children[#sibling.children] -- The last child for left direction
      elseif direction == "up" or direction == "down" then
        sibling = sibling.children[1] -- The first child for up direction
      end
    end

    return sibling
  else
    -- No sibling found, move up the tree and try again
    return self:findClosestNodeInDirection(root, current.parent, direction)
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
