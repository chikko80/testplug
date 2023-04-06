
local M = {}

local popup_bufnr = nil
local popup_winid = nil

function M.show_popup()
  if popup_bufnr and vim.api.nvim_buf_is_valid(popup_bufnr) then
    return
  end

  local lines = {"Popup content", "Line 2", "Line 3"}

  popup_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(popup_bufnr, 0, -1, false, lines)

  local width = 20
  local height = #lines
  local opts = {
    relative = "cursor",
    width = width,
    height = height,
    col = 0,
    row = 1,
    style = "minimal",
    border = "single",
  }

  popup_winid = vim.api.nvim_open_win(popup_bufnr, false, opts)
end

function M.hide_popup()
  if popup_winid and vim.api.nvim_win_is_valid(popup_winid) then
    vim.api.nvim_win_close(popup_winid, true)
    popup_winid = nil
  end

  if popup_bufnr and vim.api.nvim_buf_is_valid(popup_bufnr) then
    vim.api.nvim_buf_delete(popup_bufnr, { force = true })
    popup_bufnr = nil
  end
end



vim.api.nvim_set_keymap("n", "<C-e>", ":lua require('test').show_popup()<CR>", {noremap = true})
-- vim.api.nvim_set_keymap("n", "<C-e>", "<cmd>require('test').hide_popup()<CR>", {noremap = true, expr = true})






return M
