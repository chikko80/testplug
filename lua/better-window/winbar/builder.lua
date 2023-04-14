local utils = require("better-window.utils")
local main = require("better-window")

-- local tabufline = require("better-window.tabufline.modules")
local devicons_present, devicons = pcall(require, "nvim-web-devicons")
local M = {}

vim.api.nvim_set_hl(0, "WinBarPath", { bg = "#dedede", fg = "#363636" })
vim.api.nvim_set_hl(0, "WinBarModified", { bg = "#dedede", fg = "#ff3838" })

function M.build()
	local win_ids = utils.get_layout()

    print(main.get_windows_manager())

	local tabline_string = ""
	for _, win_id in ipairs(win_ids) do
		local buf_id = vim.api.nvim_win_get_buf(win_id)
		local name = vim.api.nvim_buf_get_name(buf_id)
		local file_info = M.get_file_info(name, buf_id)


        vim.api.nvim_set_option_value("winbar", file_info, { scope = "local", win = win_id })
	end

end

function M.get_file_info(name, bufnr)
	if devicons_present then
		local icon, icon_hl = devicons.get_icon(name, string.match(name, "%a+$"))
		print(icon, icon_hl)

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
