local M = {
    "gbprod/substitute.nvim",
    config = function()
        local substitute = require("substitute")

        substitute.setup {
            highlight_substituted_text = {
                enabled = false,
            }
        }

        local map = require("config.utils").map

        -- no one cares about the sleep operator...
        map("n", "gs", substitute.operator)
        map("n", "gss", substitute.line)
        map("n", "gS", substitute.eol)
        map("x", "gs", substitute.visual)

        -- i dont really want to override gx, but it makes more sense this way
        local exchange = require("substitute.exchange")
        map("n", "gx", exchange.operator)
        map("n", "gxx", exchange.line)
        map("x", "gx", exchange.visual)

        map("n", "go", function()
            vim.ui.open(vim.fn.expand("<cfile>"))
        end)

        map("x", "go", function()
            local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
            vim.ui.open(table.concat(vim.iter(lines):map(vim.trim):totable()))
        end)
    end
}


return M
