local M = {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
}

M.config = function()
    require("ibl").setup {
        indent = {
            highlight = {
                "IndentBlanklineChar"
            },
        },
        scope = {
            show_end = false,
            highlight = {
                "IndentBlanklineCharActive",
            },
            include = {
                node_type = {
                    lua = {
                        "return_statement",
                        "table_constructor"
                    },
                }
            }
        }
    }

    ---@Hack, should be replaced by a better solution at some point
    for i=1, 5 do
        vim.api.nvim_set_hl(0, "@ibl.scope.underline." .. tostring(i), {link = "TreesitterContext"})
    end
end

return M
