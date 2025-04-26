---@type LazySpec
local M = {
    "m4xshen/autoclose.nvim",
    event = { "InsertEnter" },
}

local text_types = {
    "text",
    "markdown",
    "typst",
    "latex",
}

local markup_types = {
    "typst",
    "markdown"
}

local xml_types = {
    "xml",
    "html"
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
        -- don't mess up my apostrophes
        ["'"] = { escape = true, close = true, pair = "''", disabled_filetypes = text_types },
        ["`"] = { escape = true, close = true, pair = "``" },
        ["$"] = { escape = true, close = true, pair = "$$", enabled_filetypes = markup_types },
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
