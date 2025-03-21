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

        -- basically a better "yank" for exchanging
        local exchange = require("substitute.exchange")
        map("n", "gy", exchange.operator)
        map("n", "gyy", exchange.line)
        map("x", "gy", exchange.visual)
    end
}


return M
