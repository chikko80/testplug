local function get_list_index(list, target)
	local index = nil

	for i, v in ipairs(list) do
		if v == target then
			index = i
			break
		end
	end
	return index
end

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

local function get_open_buffer_per_win(win_id)
	return vim.api.nvim_win_get_buf(win_id)
end

return {
	get_list_index = get_list_index,
	get_layout = get_layout,
	get_layout_diff = get_layout_diff,
	get_open_buffer_per_win = get_open_buffer_per_win,
}
