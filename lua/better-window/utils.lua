local function get_win_and_buf_id()
	local winId = vim.api.nvim_get_current_win()
	local bufId = vim.api.nvim_get_current_buf()
	return winId, bufId
end

local function get_tabs()
	local tabs = vim.api.nvim_list_tabpages()
	return tabs
end

local function get_layout(tab_id) -- just a list of window ids
	local valid_winid = {}

	local windows = vim.api.nvim_tabpage_list_wins(tab_id)
	for _, win_id in ipairs(windows) do
		local window_config = vim.api.nvim_win_get_config(win_id)
		-- print(vim.inspect(window_config))

		-- Check if the window is not floating
		if window_config.relative == "" then
			local buffer_number = vim.api.nvim_win_get_buf(win_id)
			-- extract file_name
			local bufname = vim.api.nvim_buf_get_name(buffer_number):match("([^/]+)$")

			-- Exclude windows with a buffer name matching "NvimTree"
			if not bufname or not bufname:match("^NvimTree") then
				-- print(vim.inspect(window_config))
				table.insert(valid_winid, win_id)
			end
		end
	end
	return valid_winid
end

local function get_list_diff(old_layout, new_layout)
	-- present in the old_layout but not in the new_layout
	local difference = {}
	local list2_set = {}

	-- Create a set for new_layout for faster lookup
	for _, value in ipairs(new_layout) do
		list2_set[value] = true
	end

	-- Iterate through list1 and check if the value is present in list2_set
	for _, value in ipairs(old_layout) do
		if not list2_set[value] then
			table.insert(difference, value)
		end
	end

	return difference
end

--- Find the closest pane in the specified direction from the current pane.
--
-- This function takes the current pane and the direction as input and finds the closest pane in that direction.
-- The input direction can be one of the following: "left", "right", "up", or "down".
--
-- @param panes List of panes represented by winIds.
-- @param current_pane The current pane from which the search is initiated.
-- @param direction The direction to search for the closest pane. Can be one of the following: "left", "right", "up", or "down".
-- @return The closest pane in the specified direction from the current pane.
--
-- Example usage:
-- local closest_pane = find_closest_pane(current_pane, "down")
function find_closest_pane(panes, current_pane, direction)
	local closest_pane = nil
	local min_distance = math.huge
	local min_cursor_distance = math.huge
	local min_pane_id = math.huge
	local opposite_direction = {
		left = "right",
		right = "left",
		up = "down",
		down = "up",
	}

	-- Calculate the edge center coordinates of the current pane in the specified direction
	local current_pane_edge_center = { get_edge_center(current_pane, direction) }

	-- Get the current cursor position in the current pane
	local cursor_position = vim.api.nvim_win_get_cursor(current_pane)
	local cursor_x, cursor_y = cursor_position[2], cursor_position[1]

	-- Iterate through all the panes in the layout
	for _, pane in ipairs(panes) do
		-- Skip the current pane
		if pane == current_pane then
			goto continue
		end

		-- Calculate the edge center coordinates of the candidate pane in the opposite direction
		local pane_edge_center = { get_edge_center(pane, opposite_direction[direction]) }
		local same_axis = false

		if direction == "left" or direction == "right" then
			same_axis = are_coordinates_same(current_pane_edge_center[1], pane_edge_center[1])
		elseif direction == "up" or direction == "down" then
			same_axis = are_coordinates_same(current_pane_edge_center[2], pane_edge_center[2])
		end

		-- If the candidate pane is on the same axis, calculate the distances
		if same_axis then
			-- Calculate the distance between the current pane and the candidate pane
			local distance = calculate_distance(current_pane_edge_center, pane_edge_center)
			local rounded_distance = math.floor(distance + 0.5)

			-- Calculate the cursor position distance between the current pane and the candidate pane
			local cursor_distance = calculate_distance({ cursor_x, cursor_y }, pane_edge_center)
			local rounded_cursor_distance = math.floor(cursor_distance + 0.5)

			-- Update the closest pane if the conditions are met
			if
				(rounded_distance < min_distance)
				or (rounded_distance == min_distance and rounded_cursor_distance < min_cursor_distance)
				or (
					rounded_distance == min_distance
					and rounded_cursor_distance == min_cursor_distance
					and pane < min_pane_id
				)
			then
				min_distance = rounded_distance
				min_cursor_distance = rounded_cursor_distance
				min_pane_id = pane
				closest_pane = pane
			end
		end

		::continue::
	end

	return closest_pane
end

function are_coordinates_same(coord1, coord2)
	local distance = math.abs(coord1 - coord2)
	return distance <= 3 -- give more to properly work on complex layouts
end

function get_edge_center(win_id, direction)
	local pos = vim.api.nvim_win_get_position(win_id)
	local pos_x = pos[2]
	local pos_y = pos[1]
	local width = vim.api.nvim_win_get_width(win_id)
	local height = vim.api.nvim_win_get_height(win_id)

	if direction == "left" then
		local center_x = pos_x
		local center_y = pos_y + (height / 2)
		return center_x, center_y
	elseif direction == "right" then
		local center_x = pos_x + width
		local center_y = pos_y + (height / 2)
		return center_x, center_y
	elseif direction == "up" then
		local center_x = pos_x + (width / 2)
		local center_y = pos_y
		return center_x, center_y
	elseif direction == "down" then
		local center_x = pos_x + (width / 2)
		local center_y = pos_y + height
		return center_x, center_y
	else
		error("Invalid direction. Must be 'left', 'right', 'up', or 'down'.")
	end
end

function calculate_distance(center1, center2)
	local dx = center2[1] - center1[1]
	local dy = center2[2] - center1[2]
	return math.sqrt(dx * dx + dy * dy)
end

local function darken_hex_color(hex_color, factor)
	-- Convert hex color to RGB components
	local r, g, b =
		tonumber(hex_color:sub(2, 3), 16), tonumber(hex_color:sub(4, 5), 16), tonumber(hex_color:sub(6, 7), 16)

	-- Apply the darkening factor
	r = math.floor(math.max(0, r * factor))
	g = math.floor(math.max(0, g * factor))
	b = math.floor(math.max(0, b * factor))

	-- Convert the modified RGB components back to a hex color
	local darker_hex_color = string.format("#%02X%02X%02X", r, g, b)
	return darker_hex_color
end

local function get_winnr_to_win_id_mapper(tabId)
	local win_ids = get_layout(tabId)
	local winnr_to_id = {}
	for _, win_id in ipairs(win_ids) do
		local winnr = vim.fn.win_id2win(win_id)
		winnr_to_id[winnr] = win_id
	end
	return winnr_to_id
end

return {
	get_tabs = get_tabs,
	get_layout = get_layout,
	get_list_diff = get_list_diff,
	find_closest_pane = find_closest_pane,
	get_win_and_buf_id = get_win_and_buf_id,
	darken_hex_color = darken_hex_color,
	get_winnr_to_win_id_mapper = get_winnr_to_win_id_mapper,
}
