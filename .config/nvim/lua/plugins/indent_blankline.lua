local M = {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
}

M.opts = {
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

return M
