local utils = require("better-window.utils")


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

function find_closest_pane(panes, current_pane, direction)
	local closest_pane = nil
	local min_distance = math.huge

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
			if distance < min_distance then
				min_distance = distance
				closest_pane = pane
			end
		end

		::continue::
	end

	return closest_pane
end

function test()
	-- utils layout returns a table of window ids in the current tabpage
	for i, win in ipairs(utils.get_layout()) do
		local pos = vim.api.nvim_win_get_position(win)
		-- print("Window " .. i .. " position: ", pos[1], pos[2])

		-- print(get_center(win))
		print(vim.inspect(find_closest_pane(utils.get_layout(), win, "right")))
	end
end

return {
	test = test,
}
