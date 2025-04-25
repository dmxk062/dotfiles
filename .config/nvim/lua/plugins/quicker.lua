---@type LazySpec
local M = {
    "stevearc/quicker.nvim",
}

---@type quicker.Config
---@diagnostic disable-next-line: missing-fields
M.opts = {
    opts = {
        buflisted = true,
        signcolumn = "no",
    },
    keys = {
        { ">", function()
            require("quicker").expand()
        end },
        { "<", function()
            require("quicker").collapse()
        end },
    },
    type_icons = {
        E = "E",
        W = "W",
        I = "I",
        H = "H",
        N = ".",
    },
    borders = {
        vert = "│",

        strong_header = "─",
        strong_cross = "┼",
        strong_end = "┤",

        soft_header = "─",
        soft_cross = "┼",
        soft_end = "┤",
    },
}

return M
