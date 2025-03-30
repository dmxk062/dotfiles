-- Spec {{{
---@type LazySpec
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
-- }}}

-- Textobjects {{{
local textobjects = {}
textobjects.select = {
    enable = true,
    lookahead = true,
    keymaps = {
        -- function declarations
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        -- function calls
        ["iF"] = "@call.inner",
        ["aF"] = "@call.outer",
        -- read: inside/around argument
        ["ia"] = "@parameter.inner",
        ["aa"] = "@parameter.outer",
        -- value
        ["iv"] = "@assignment.rhs",
        -- name
        ["in"] = "@assignment.lhs",
        -- comment
        ["ic"] = "@comment.inner",
        ["ac"] = "@comment.outer",
        -- loops
        ["il"] = "@loop.inner",
        ["al"] = "@loop.outer",
        -- conditionals
        ["i?"] = "@conditional.inner",
        ["a?"] = "@conditional.outer",
        -- [k]lasses/structs
        ["ik"] = "@class.inner",
        ["ak"] = "@class.outer",
        -- numbers
        ["i1"] = "@number.inner",

        -- blocks
        ["i<space>"] = "@block.inner",
        ["a<space>"] = "@block.outer",
    }
}
-- }}}

-- Bracket Movement {{{
textobjects.move = {
    enable = true,
    goto_next_start = {
        ["]a"] = "@parameter.inner",
        ["]f"] = "@function.outer",
        ["]m"] = "@method.outer",
        ["]C"] = "@comment.outer",
        ["]t"] = "@class.outer",
        ["]v"] = "@assignment.lhs",
        ["]l"] = "@loop.outer",
        ["]["] = "@block.outer",
    },
    goto_previous_start = {
        ["[a"] = "@parameter.inner",
        ["[f"] = "@function.outer",
        ["[m"] = "@method.outer",
        ["[C"] = "@comment.outer",
        ["[t"] = "@class.outer",
        ["[v"] = "@assignment.lhs",
        ["[l"] = "@loop.outer",
        ["[]"] = "@block.outer",
    },

    goto_next_end = {
        ["]A"] = "@parameter.inner",
        ["]F"] = "@function.outer",
        ["]M"] = "@method.outer",
        ["]]"] = "@block.inner",
    },
    goto_previous_end = {
        ["[A"] = "@parameter.inner",
        ["[F"] = "@function.outer",
        ["[M"] = "@method.outer",
        ["[["] = "@block.inner",
    },
}
-- }}}

-- Swap {{{
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
-- }}}

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
        ignore_install = {},

        modules = {},

        sync_install = false,
        auto_install = true,

        highlight = {
            enable = true,

            disable = function(lang, buf)
                local max_filesize = 4 * 1024 * 1024
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,

            additional_vim_regex_highlighting = false,
        },

        indent = {
            enable = true
        },

        textobjects = textobjects,
        matchup = {
            enable = true,
            disable_virtual_text = true,
        }
    }

    -- use the builtin repeat
    local ts_repeat = require("nvim-treesitter.textobjects.repeatable_move")
    vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat.repeat_last_move_next)
    vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat.repeat_last_move_previous)

    -- enable it for [fFtT]
    -- for _, motion in pairs({ "f", "F", "t", "T" }) do
    --     vim.keymap.set({ "n", "x", "o" }, motion, ts_repeat["builtin_" .. motion .. "_expr"], { expr = true })
    -- end

    -- additional repeat movements for plugins
    local nd, pd = ts_repeat.make_repeatable_move_pair(
        function() vim.diagnostic.jump { count = 1, float = false } end,
        function() vim.diagnostic.jump { count = -1, float = false } end
    )
    vim.keymap.set({ "n", "x", "o" }, "]d", nd)
    vim.keymap.set({ "n", "x", "o" }, "[d", pd)


    for _, severity in ipairs(vim.diagnostic.severity) do
        local nb, pb = ts_repeat.make_repeatable_move_pair(
            function() vim.diagnostic.jump { count = 1, float = false, severity = severity } end,
            function() vim.diagnostic.jump { count = -1, float = false, severity = severity } end
        )

        local key = severity:sub(1, 1):lower()
        vim.keymap.set({ "n", "x", "o" }, "]" .. key, nb)
        vim.keymap.set({ "n", "x", "o" }, "[" .. key, pb)
    end
end

return M
