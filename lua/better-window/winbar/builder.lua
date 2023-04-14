local utils = require("better-window.utils")
local devicons_present, devicons = pcall(require, "nvim-web-devicons")
local M = {}

local tab_manager

vim.api.nvim_set_hl(0, "WinBarPath", { bg = "#dedede", fg = "#363636" })
vim.api.nvim_set_hl(0, "WinBarModified", { bg = "#dedede", fg = "#ff3838" })

function M.init(_tab_manager)
	tab_manager = _tab_manager
end

function M.build()
	local win_ids = utils.get_layout()

	local tabId = vim.api.nvim_get_current_tabpage()
	local windows_manager = tab_manager:get_windows_manager(tabId)


	for _, win_id in ipairs(win_ids) do
        local tabline_string = M.build_for_editor_group(windows_manager, win_id)
		vim.api.nvim_set_option_value("winbar", tabline_string, { scope = "local", win = win_id })
	end
end

function M.build_for_editor_group(windows_manager, win_id)
	local editors = windows_manager:getEditorGroup(win_id).items


	local tabline_string = ""
	for _, bufnr in ipairs(editors) do
		local name = vim.api.nvim_buf_get_name(bufnr)
		local file_info = M.get_file_info(name, bufnr)
		tabline_string = tabline_string .. file_info .. " "
	end
	return tabline_string
end

function M.get_file_info(name, bufnr)
	if devicons_present then
		local icon, icon_hl = devicons.get_icon(name, string.match(name, "%a+$"))

		if not icon then
			icon = ""
			icon_hl = "DevIconDefault"
		end

		-- padding around bufname; 24 = bufame length (icon + filename)
		local padding = (24 - #name - 6) / 2

		name = vim.api.nvim_buf_get_name(bufnr):match("([^/]+)$")

		return string.rep(" ", padding) .. icon .. " " .. name .. string.rep(" ", padding)
	end
end

return M
