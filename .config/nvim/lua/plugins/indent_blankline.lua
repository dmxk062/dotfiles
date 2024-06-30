local M = {
    "lukas-reineke/indent-blankline.nvim",
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
            highlight = "IndentBlanklineCharActive",
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
end

return M
