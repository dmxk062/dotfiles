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
        U = ".",
    },
    borders = {
        vert = " ",

        strong_header = "─",
        strong_cross = "┼",
        strong_end = "┤",

        soft_header = "─",
        soft_cross = "┼",
        soft_end = "┤",
    },
    max_filename_width = function()
        return math.floor(math.min(40, vim.o.columns / 4))
    end
}

return M
