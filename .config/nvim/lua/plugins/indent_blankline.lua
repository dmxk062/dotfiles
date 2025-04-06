---@type LazySpec
local M = {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
}

---@type ibl.config
M.opts = {
    indent = {
        highlight = {
            "IndentBlanklineIndent"
        },
    },
    scope = {
        highlight = {
            "IndentBlanklineScope",
        },
        include = {
            node_type = {
                lua = {
                    "return_statement",
                    "table_constructor"
                },
            }
        }
    },
    exclude = {
        filetypes = {
            "undotree",
        }
    }
}

return M
