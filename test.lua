local api = vim.api

-- Function to handle selection
local function on_choice(selected_idx)
	if selected_idx < 1 then
		print("No selection made")
	else
		print("Selected item: " .. selected_idx)
		-- Handle your selection here
	end
end

local function show_popup()
	local items = { "Item 1", "Item 2", "Item 3" }

	-- Create buffer and window for the popup
	local buf = api.nvim_create_buf(false, true)
	local win = api.nvim_open_win(buf, false, {
		relative = "editor",
		width = 20,
		height = #items + 2,
		row = math.floor((vim.o.lines - #items - 2) / 2),
		col = math.floor((vim.o.columns - 20) / 2),
		border = "rounded",
	})

	api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- Add items to the buffer
	for i, item in ipairs(items) do
		api.nvim_buf_set_lines(buf, i - 1, i, false, { item })
	end

	-- Set up key mappings
	local function close_popup()
		api.nvim_win_close(win, true)
	end

	local function on_enter()
		local selected_idx = api.nvim_win_get_cursor(win)[1]
		close_popup()
		on_choice(selected_idx)
	end

	local keys = {
		["<CR>"] = on_enter,
		["<Esc>"] = close_popup,
	}

	for k, v in pairs(keys) do
		api.nvim_buf_set_keymap(buf, "n", k, "<Cmd>lua " .. v .. "<CR>", { silent = true })
	end

	-- Focus the popup window
	api.nvim_set_current_win(win)
end

show_popup()
