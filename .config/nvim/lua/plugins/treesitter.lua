local blocked_langs = {
    -- "tex", "latex"
}

local M = {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
}

local textobjects = {}
textobjects.select = {
    enable = true,
    lookahead = true,
    keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        -- read: all arguments
        ["aA"] = "@call.inner",
        -- read: inside/around argument
        ["ia"] = "@parameter.inner",
        ["aa"] = "@parameter.outer",
        -- variables
        -- value
        ["vv"] = "@assignment.rhs",
        -- name
        ["vn"] = "@assignment.lhs",
        -- comment
        ["ic"] = "@comment.inner",
        ["ac"] = "@comment.outer",
        -- loops
        ["iL"] = "@loop.inner",
        ["aL"] = "@loop.outer",
        -- classes/structs
        ["iC"] = "@class.inner",
        ["aC"] = "@class.outer",

        ---@deprecated, gonna be more useful for indents
        -- read: inner if
        -- ["ii"] = "@conditional.inner",
        -- ["ai"] = "@conditional.outer",

        -- return value
        ["ir"] = "@return.inner",
        ["ar"] = "@return.outer",
    }
}
textobjects.move = {
    enable = true,
    goto_next_start = {
        ["]a"] = "@parameter.inner",
        ["]f"] = "@function.outer",
        ["]m"] = "@function.outer",
        ["]c"] = "@comment.outer",
        ["]r"] = "@return.inner",
    },
    goto_previous_start = {
        ["[a"] = "@parameter.inner",
        ["[f"] = "@function.outer",
        ["[m"] = "@function.outer",
        ["[c"] = "@comment.outer",
        ["[r"] = "@return.inner",
    },

    goto_next_end = {
        ["]F"] = "@function.outer",
        ["]M"] = "@function.outer",

    },
    goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[M"] = "@function.outer",

    },
}

M.config = function()
    require("nvim-treesitter.configs").setup {
        ensure_installed = {
            "c",
            "cpp",
            "bash",
            "json",
            "jsonc",
            "latex",
            "scss",
            "css",
            "asm",
            "lua",
            "python",
            "vim",
            "vimdoc",
            "query",
            "markdown",
            "markdown_inline",
        },

        sync_install = false,
        auto_install = true,

        highlight = {
            enable = true,

            disable = function(lang, buf)
                for _, l in ipairs(blocked_langs) do
                    if l == lang then
                        return true
                    end
                end

                local max_filesize = 500 * 1024
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,

            additional_vim_regex_highlighting = false,
        },

        textobjects = textobjects,

    }
end

return M
