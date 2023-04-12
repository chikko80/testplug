-- GridLayout
local GridLayout = {}
GridLayout.__index = GridLayout

function GridLayout.new()
	local self = setmetatable({}, GridLayout)
	self.rows = 1
	self.columns = 1
	self.grid = {}
	for _ = 1, self.rows do
		local row = {}
		for _ = 1, self.columns do
			table.insert(row, nil)
		end
		table.insert(self.grid, row)
	end
	return self
end

function GridLayout:resizeGrid(newRows, newColumns)
	local newGrid = {}
	for r = 1, newRows do
		local row = {}
		for c = 1, newColumns do
			if r <= self.rows and c <= self.columns then
				row[c] = self.grid[r][c]
			else
				row[c] = nil
			end
		end
		newGrid[r] = row
	end
	self.grid = newGrid
	self.rows = newRows
	self.columns = newColumns
end

function GridLayout:splitPane(win_id, command)
	local srcRow, srcCol = self:getPanePosition(win_id)
	if command == "vsplit" then
		if self.columns < 2 then
			self:resizeGrid(self.rows, self.columns + 1)
		end
		local newRow = srcRow
		local newCol = srcCol + 1
		return newRow, newCol
	elseif command == "split" then
		if self.rows < 2 then
			self:resizeGrid(self.rows + 1, self.columns)
		end
		local newRow = srcRow + 1
		local newCol = srcCol
		return newRow, newCol
	end
end

function GridLayout:getPanePosition(win_id)
	for row = 1, self.rows do
		for col = 1, self.columns do
			if self.grid[row][col] and self.grid[row][col].winnr == win_id then
				return row, col
			end
		end
	end
	return nil, nil
end

function GridLayout:addEditorGroup(editorGroup, row, column)
	self.grid[row][column] = editorGroup
end

function GridLayout:removeEditorGroup(row, column)
	self.grid[row][column] = nil
end

function GridLayout:moveEditorGroup(srcRow, srcCol, dstRow, dstCol)
	local editorGroup = self.grid[srcRow][srcCol]
	self.grid[srcRow][srcCol] = nil
	self.grid[dstRow][dstCol] = editorGroup
end

return GridLayout
