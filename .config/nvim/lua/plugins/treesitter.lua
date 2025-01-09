local M = {
    event = { "BufReadPost", "BufNewFile", "FileType" },
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        {
            "nvim-treesitter/nvim-treesitter-context",
            opts = {
                enable = true,
                max_lines = 0,
            }
        },
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
        -- value
        ["iv"] = "@assignment.rhs",
        -- name
        ["iN"] = "@assignment.lhs",
        -- comment
        ["ic"] = "@comment.inner",
        ["ac"] = "@comment.outer",
        -- loops
        ["il"] = "@loop.inner",
        ["al"] = "@loop.outer",
        -- classes/structs
        ["iC"] = "@class.inner",
        ["aC"] = "@class.outer",
        -- numbers
        ["in"] = "@number.inner",
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
        ["]m"] = "@method.outer",
        ["]c"] = "@comment.outer",
        ["]C"] = "@class.outer",
        ["]r"] = "@return.inner",
        ["]v"] = "@assignment.lhs",
        ["]l"] = "@loop.outer",
    },
    goto_previous_start = {
        ["[a"] = "@parameter.inner",
        ["[f"] = "@function.outer",
        ["[m"] = "@method.outer",
        ["[c"] = "@comment.outer",
        ["[C"] = "@class.outer",
        ["[r"] = "@return.inner",
        ["[v"] = "@assignment.lhs",
        ["[l"] = "@loop.outer",
    },

    goto_next_end = {
        ["]F"] = "@function.outer",
        ["]M"] = "@method.outer",

    },
    goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[M"] = "@method.outer",

    },
}

textobjects.swap = {
    enable = true,
    swap_next = {
        ["g>a"] = "@parameter.inner",
        ["g>f"] = "@function.outer",
    },

    swap_previous = {
        ["g<a"] = "@parameter.inner",
        ["g<f"] = "@function.outer",
    },
}

M.config = function()
    require("nvim-treesitter.configs").setup {
        ensure_installed = {
            "asm",
            "awk",
            "bash",
            "c",
            "cpp",
            "css",
            "jq",
            "json",
            "jsonc",
            "latex",
            "lua",
            "markdown",
            "markdown_inline",
            "printf",
            "python",
            "query",
            "scss",
            "vim",
            "vimdoc",
        },

        sync_install = false,
        auto_install = true,

        highlight = {
            enable = true,

            disable = function(lang, buf)
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

    -- use the builtin repeat
    local ts_repeat = require("nvim-treesitter.textobjects.repeatable_move")
    vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat.repeat_last_move_next)
    vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat.repeat_last_move_previous)

    -- enable it for [fFtT]
    for _, motion in pairs({ "f", "F", "t", "T" }) do
        vim.keymap.set({ "n", "x", "o" }, motion, ts_repeat["builtin_" .. motion .. "_expr"], { expr = true })
    end

    -- additional repeat movements for plugins
    local gs = require("gitsigns")
    local nh, ph = ts_repeat.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
    vim.keymap.set({ "n", "x", "o" }, "]g", nh)
    vim.keymap.set({ "n", "x", "o" }, "[g", ph)
    local nd, pd = ts_repeat.make_repeatable_move_pair(
        function() vim.diagnostic.goto_next { float = false } end,
        function() vim.diagnostic.goto_prev { float = false } end
    )
    vim.keymap.set({ "n", "x", "o" }, "]d", nd)
    vim.keymap.set({ "n", "x", "o" }, "[d", pd)
end

return M
