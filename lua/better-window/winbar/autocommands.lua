print("calling")

-- vim.api.nvim_create_autocmd({ "InsertEnter"  }, {
vim.api.nvim_create_autocmd({
	"WinEnter",
	"BufEnter",
	"BufWinEnter",
}, {

	callback = function()
		vim.schedule_wrap(require("better-window.winbar.builder").build())
	end,
})
