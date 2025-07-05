---@type LazySpec
local M = {
    "luukvbaal/statuscol.nvim",
}

M.config = function()
    local builtin = require("statuscol.builtin")

    local segments = {
        {
            text = {
                builtin.foldfunc,
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
            sign = {
                namespace = { ".*" },
                auto = true
            }
        },
        {
            text = {
                builtin.lnumfunc,
                " "
            },
            condition = {
                builtin.not_empty
            },
            click = "v:lua.ScLa",
        },
    }
    require("statuscol").setup {
        ft_ignore = {
            "help"
        },
        relculright = true,
        segments = segments,
    }
end

return M
