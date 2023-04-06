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

local function get_open_windows()
	local current_tab = vim.api.nvim_get_current_tabpage()

	local valid_winid = {}

	local windows = vim.api.nvim_tabpage_list_wins(current_tab)
	for _, win_id in ipairs(windows) do
		local buffer_number = vim.api.nvim_win_get_buf(win_id)
		-- extract file_name
		local bufname = vim.api.nvim_buf_get_name(buffer_number):match("([^/]+)$")
		-- if not empty and not NvimTree
		if bufname ~= nil and not bufname:match("^NvimTree") then
			table.insert(valid_winid, win_id)
		end
	end
	return valid_winid
end

local function get_open_buffer_per_win(win_id)
	return vim.api.nvim_win_get_buf(win_id)
end


return {
    get_list_index = get_list_index,
    get_open_windows = get_open_windows,
    get_open_buffer_per_win = get_open_buffer_per_win,

}
