local M = {
    "tpope/vim-fugitive",
    dependencies = {
        "tpope/vim-rhubarb",
    }
}

M.config = function ()
    vim.g.fugitive_dynamic_colors = false

    vim.api.nvim_create_autocmd({"User"}, {
        pattern = "FugitiveIndex",
        callback = function(ev)
            -- enable folding and fold by default
            vim.wo[0][0].foldmethod = "syntax"
            vim.wo[0][0].foldlevel = 0
        end
    })
end


return M
