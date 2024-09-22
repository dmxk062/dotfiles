local M = {
    "luukvbaal/statuscol.nvim",
}

M.config = function()
    require("statuscol").setup {
        segments = {
            {
                text = {
                    require("statuscol.builtin").foldfunc,
                    " "
                },
                click = "v:lua.ScFa"
            },
            {
                text = {
                    require("statuscol.builtin").lnumfunc,
                    " "
                },
                condition = {
                    true,
                    require("statuscol.builtin").not_empty
                },
                click = "v:lua.ScLa",
            },
            {
                text = { "%s" },
                click = "v:lua.ScSa"
            },
        },
    }
end

return M
