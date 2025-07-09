---@type LazySpec
local M = {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile", "FileType" },
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
        ["]k"] = "@class.outer",
        ["]v"] = "@assignment.lhs",
        ["]l"] = "@loop.outer",
    },
    goto_previous_start = {
        ["[a"] = "@parameter.inner",
        ["[f"] = "@function.outer",
        ["[m"] = "@method.outer",
        ["[C"] = "@comment.outer",
        ["[k"] = "@class.outer",
        ["[v"] = "@assignment.lhs",
        ["[l"] = "@loop.outer",
    },

    goto_next_end = {
        ["]A"] = "@parameter.inner",
        ["]F"] = "@function.outer",
        ["]M"] = "@method.outer",
    },
    goto_previous_end = {
        ["[A"] = "@parameter.inner",
        ["[F"] = "@function.outer",
        ["[M"] = "@method.outer",
    },
}
-- }}}

-- Swap {{{
textobjects.swap = {
    enable = true,
    swap_next = {
        [">,"] = "@parameter.inner",
    },

    swap_previous = {
        ["<,"] = "@parameter.inner",
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
            "luadoc",
            "luap",
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

    local utils = require("config.utils")
    local map = utils.map
    local modes = { "n", "x", "o" }
    -- use the builtin repeat
    local ts_repeat = require("nvim-treesitter.textobjects.repeatable_move")
    map(modes, ";", ts_repeat.repeat_last_move_next)
    map(modes, ",", ts_repeat.repeat_last_move_previous)

    -- enable it for [fFtT]
    -- for _, motion in pairs({ "f", "F", "t", "T" }) do
    --     map(modes, motion, ts_repeat["builtin_" .. motion .. "_expr"], { expr = true })
    -- end

    -- additional repeat movements for plugins
    local nd, pd = ts_repeat.make_repeatable_move_pair(
        function() vim.diagnostic.jump { count = 1, float = false } end,
        function() vim.diagnostic.jump { count = -1, float = false } end
    )
    map(modes, "]d", nd)
    map(modes, "[d", pd)

    for _, severity in ipairs(vim.diagnostic.severity) do
        local nb, pb = ts_repeat.make_repeatable_move_pair(
            function() vim.diagnostic.jump { count = 1, float = false, severity = severity } end,
            function() vim.diagnostic.jump { count = -1, float = false, severity = severity } end
        )

        local key = severity --[[@as string]]:sub(1, 1):lower()
        map(modes, "]" .. key, nb)
        map(modes, "[" .. key, pb)
    end

    local builtin_brackets = {
        "s", -- spelling errors
        "z", -- folds
    }
    local bracket_with_count = function(command)
        return function()
            local ok, err = pcall(vim.api.nvim_cmd, {
                cmd = "normal",
                bang = true,
                args = { vim.v.count1 .. command }
            }, { output = false })
            if not ok then
                utils.error("Map/" .. command, err:gsub("^Vim:E%d+:%s*", ""))
            end
        end
    end
    for _, key in pairs(builtin_brackets) do
        local fwd = "]" .. key
        local bwd = "[" .. key
        local nb, pb = ts_repeat.make_repeatable_move_pair(
            bracket_with_count(fwd),
            bracket_with_count(bwd)
        )
        map(modes, fwd, nb)
        map(modes, bwd, pb)
    end
end

return M
