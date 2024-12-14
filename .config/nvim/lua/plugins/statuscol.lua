local M = {
    "luukvbaal/statuscol.nvim",
}

M.config = function()
    require("statuscol").setup {
        ft_ignore = {
            "help"
        },
        relculright = true,
        segments = {
            {
                text = {
                    require("statuscol.builtin").foldfunc,
                    ""
                },
                click = "v:lua.ScFa"
            },
            {
                sign = {
                    namespace = { "gitsigns.*" },
                    maxwidth = 1,
                },
                click = "v:lua.ScSa",
            },
            {
                text = {
                    require("statuscol.builtin").lnumfunc,
                    " "
                },
                condition = {
                    require("statuscol.builtin").not_empty
                },
                click = "v:lua.ScLa",
            },
            {
                -- HACK: dont show the second column
                sign = {
                    namespace = { "oil.*" },
                    maxwidth = 1,
                    auto = true
                },
            },
            {
                sign = {
                    namespace = { "quicker.*" },
                    auto = true,
                }
            }
        },
    }
end

return M
