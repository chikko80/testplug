
local value = 'hello world'

pcall(vim.api.nvim_set_option_value, 'winbar', value, { scope = 'local' })

