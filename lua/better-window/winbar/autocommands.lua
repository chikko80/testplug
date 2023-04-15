local builder = require("better-window.winbar.builder")
print("calling")

vim.api.nvim_create_autocmd({ "InsertEnter"  }, {
-- vim.api.nvim_create_autocmd({ "DirChanged", "BufWinEnter","BufEnter","WinEnter", "BufLeave", "WinNew", "InsertEnter"  }, {

	callback = function()
		builder.build()
	end,
})
