local builder = require("better-window.winbar.builder")
print("calling")

vim.api.nvim_create_autocmd({ "DirChanged", "InsertEnter", "BufWritePost" }, {

	callback = function()
		print("callback")
		builder.build()
	end,
})
