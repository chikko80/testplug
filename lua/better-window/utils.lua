local function get_layout() -- just a list of window ids
	local current_tab = vim.api.nvim_get_current_tabpage()

	local valid_winid = {}

	local windows = vim.api.nvim_tabpage_list_wins(current_tab)
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

local function get_layout_diff(old_layout, new_layout)
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

function calculate_angle(center1, center2)
	local dx = center2[1] - center1[1]
	local dy = center2[2] - center1[2]
	return math.atan2(dy, dx)
end

function get_center(win_id)
	local pos = vim.api.nvim_win_get_position(win_id)
	local pos_x = pos[2]
	local pos_y = pos[1]
	local width = vim.api.nvim_win_get_width(win_id)
	local height = vim.api.nvim_win_get_height(win_id)

	local center_x = pos_x + (width / 2)
	local center_y = pos_y + (height / 2)

	return center_x, center_y
end

function calculate_distance(center1, center2)
	local dx = center2[1] - center1[1]
	local dy = center2[2] - center1[2]
	return math.sqrt(dx * dx + dy * dy)
end

function find_closest_pane(current_pane, direction)
	local panes = get_layout()
	local closest_pane = nil
	local min_distance = math.huge
	local min_pane_id = math.huge

	for _, pane in ipairs(panes) do
		if pane == current_pane then
			goto continue
		end

		local current_pane_center = { get_center(current_pane) }
		local pane_center = { get_center(pane) }

		if
			direction == "left" and pane_center[1] < current_pane_center[1]
			or direction == "right" and pane_center[1] > current_pane_center[1]
			or direction == "up" and pane_center[2] < current_pane_center[2]
			or direction == "down" and pane_center[2] > current_pane_center[2]
		then
			local distance = calculate_distance(current_pane_center, pane_center)

			if distance < min_distance or (distance == min_distance and pane < min_pane_id) then
				min_distance = distance
				min_pane_id = pane
				closest_pane = pane
			end
		end

		::continue::
	end

	return closest_pane
end

return {
	get_layout = get_layout,
	get_layout_diff = get_layout_diff,
	find_closest_pane = find_closest_pane,
}
