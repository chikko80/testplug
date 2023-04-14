
        vim.api.nvim_create_autocmd({ 'DirChanged', 'CursorMoved', 'BufWinEnter', 'BufFilePost', 'InsertEnter', 'BufWritePost' }, {
            callback = function()
                winbar.show_winbar()
            end
        })
