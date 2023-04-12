local Node = require("better-window.node")
local EditorGroup = require("better-window.editor_group")

-- TreeLayout
local TreeLayout = {}
TreeLayout.__index = TreeLayout

function TreeLayout.new()
	local self = setmetatable({}, TreeLayout)
	local initialWin = vim.api.nvim_get_current_win()
	local initialEditorGroup = EditorGroup.new(initialWin)
	self.root = Node.new(initialEditorGroup)
	return self
end

function TreeLayout:splitPane(node)
	local newNode = Node.new(EditorGroup.new(nil))
	local existingNode = Node.new(node.editorGroup)
	node.editorGroup = nil
	node.children = { existingNode, newNode }
	return newNode
end

function TreeLayout:getPaneNode(win_id, node)
	node = node or self.root

	if node.editorGroup and node.editorGroup.winnr == win_id then
		return node
	end

	for _, child in ipairs(node.children) do
		local result = self:getPaneNode(win_id, child)
		if result then
			return result
		end
	end

	return nil
end

return TreeLayout
