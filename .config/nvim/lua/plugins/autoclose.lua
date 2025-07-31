---@type LazySpec
local M = {
    "m4xshen/autoclose.nvim",
    event = { "InsertEnter" },
}

-- Don't mess up my apostrophes
-- I *will* be sad
local text_types = {
    "gitcommit",
    "latex",
    "markdown",
    "org",
    "text",
    "typst",
}

local xml_types = {
    "html",
    "xml",
}

M.opts = {
    keys = {
        ["("] = { escape = false, close = true, pair = "()" },
        ["["] = { escape = false, close = true, pair = "[]" },
        ["{"] = { escape = false, close = true, pair = "{}" },
        ["<"] = { escape = false, close = true, pair = "<>", enabled_filetypes = xml_types },

        [")"] = { escape = true, close = false, pair = "()" },
        ["]"] = { escape = true, close = false, pair = "[]" },
        ["}"] = { escape = true, close = false, pair = "{}" },
        [">"] = { escape = true, close = false, pair = "<>", enabled_filetypes = xml_types },

        ['"'] = { escape = true, close = true, pair = '""' },
        ["'"] = { escape = true, close = true, pair = "''", disabled_filetypes = text_types },
        ["`"] = { escape = true, close = true, pair = "``" },
    },
    options = {
        disable_when_touch = true,
        touch_regex = "[%w(%[{\"]",
        pair_spaces = false,
        disabled_filetypes = {
        },
    },
}

return M
