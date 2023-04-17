local utils = require("better-window.utils")
local devicons_present, devicons = pcall(require, "nvim-web-devicons")
local M = {}

local SharedState = require("better-window.state")

vim.api.nvim_set_hl(0, "ActiveEditor", { bold = true })
vim.api.nvim_set_hl(0, "InactiveEditor", { fg = "#546178", bg = "#171b21" })

function is_main_active_buffer(win_id, bufnr)
	local current_win = vim.api.nvim_get_current_win()
	local win_bufnr = vim.api.nvim_win_get_buf(win_id)

	return win_id == current_win and win_bufnr == bufnr
end

function M.build()
	local tabId = vim.api.nvim_get_current_tabpage()

	local win_ids = utils.get_layout(tabId)
	local windows_manager = SharedState.get_tab_manager():get_windows_manager(tabId)
	for _, win_id in ipairs(win_ids) do
		local tabline_string = M.build_for_editor_group(windows_manager, win_id)

		if tabline_string then
			pcall(vim.api.nvim_set_option_value, "winbar", tabline_string, { scope = "local", win = win_id })
		end
	end
end

function M.build_for_editor_group(windows_manager, win_id)
	local editor_group = windows_manager:getEditorGroup(win_id)

	if not editor_group then
		return
	end

	local tabline_string = ""
	for _, editor in pairs(editor_group.stack.items) do
		local bufnr = editor.buf_nr
		local name = editor.buf_name

		local file_info = M.get_file_info(name, win_id, bufnr)
		if not file_info then
			return
		end
		if is_main_active_buffer(win_id, bufnr) then
			-- if  active_bufnr == bufnr then
			tabline_string = tabline_string .. "%#ActiveEditor#" .. file_info
			-- tabline_string = tabline_string .. "  " .. file_info .. "  "
		else
			tabline_string = tabline_string .. "%#InactiveEditor#" .. file_info
			-- tabline_string = tabline_string .. "  " .. file_info .. "  "
		end
	end
	return tabline_string .. M.apply_hl_group("InactiveEditor", "%=")
end

function M.apply_hl_group(group, string)
	return "%#" .. group .. "#" .. string
end

function M.get_file_info(name, win_id, bufnr)
	if devicons_present then
		local icon, icon_hl = devicons.get_icon(name, string.match(name, "%a+$"))

		if not icon then
			icon = ""
			icon_hl = "DevIconDefault"
		end

		icon = (is_main_active_buffer(win_id, bufnr) and M.apply_hl_group(icon_hl, icon) or icon)

		-- padding around bufname; 24 = bufame length (icon + filename)
		local maxname_len = 16

		name = name:match("([^/]+)$")
		if not name then
			return
		end

		name = (#name > maxname_len and string.sub(name, 1, 14) .. "..") or name

		local padding = (24 - #name - 6) / 2

		name = (
			is_main_active_buffer(win_id, bufnr) and M.apply_hl_group("ActiveEditor", name)
			or M.apply_hl_group("InactiveEditor", name)
		)

		return string.rep(" ", padding) .. icon .. " " .. name .. string.rep(" ", padding)
	end
end

return M
