---@type LazySpec
local M = {
    "m4xshen/autoclose.nvim",
    event = { "InsertEnter" },
}

M.opts = {
    keys = {
        ["("] = { escape = false, close = true, pair = "()" },
        ["["] = { escape = false, close = true, pair = "[]" },
        ["{"] = { escape = false, close = true, pair = "{}" },
        ["<"] = { escape = false, close = true, pair = "<>", enabled_filetypes = { "xml", "html" } },

        [")"] = { escape = true, close = false, pair = "()" },
        ["]"] = { escape = true, close = false, pair = "[]" },
        ["}"] = { escape = true, close = false, pair = "{}" },
        [">"] = { escape = true, close = false, pair = "<>", enabled_filetypes = { "xml", "html" } },

        ['"'] = { escape = true, close = true, pair = '""' },
        -- don't mess up my apostrophes
        ["'"] = { escape = true, close = true, pair = "''", disabled_filetypes = { "text", "markdown" } },
        ["`"] = { escape = true, close = true, pair = "``" },
        ["$"] = { escape = true, close = true, pair = "$$", enabled_filetypes = { "latex" } },
    },
    options = {
        disable_when_touch = true,
        pair_spaces = false,
        disabled_filetypes = {
        },
    },
}

return M
