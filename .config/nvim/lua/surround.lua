local utils = require("utils")
require("autoclose").setup({
    keys = {
        ["("] = { escape = false, close = true, pair = "()"},
        ["["] = { escape = false, close = true, pair = "[]"},
        ["{"] = { escape = false, close = true, pair = "{}"},

        [")"] = { escape = true, close = false, pair = "()"},
        ["]"] = { escape = true, close = false, pair = "[]"},
        ["}"] = { escape = true, close = false, pair = "{}"},

        ['"'] = { escape = true, close = true, pair = '""'},
        ["'"] = { escape = true, close = true, pair = "''"},
        ["`"] = { escape = true, close = true, pair = "``"},
    },
    options = {
        disable_when_touch = true,
        -- mainly for quotes
        disabled_filetypes = {
            "text",
            "markdown"
        },
    },
})

require("nvim-surround").setup({
})

-- this saves me from typing the special chars when i want to use them in motions
-- utils.map({ "o", "x" }, "iq", 'i"') -- [q]uote
-- utils.map({ "o", "x" }, "aq", 'a"')
-- utils.map({ "o", "x" }, "iQ", "i'") -- single [Q]uote
-- utils.map({ "o", "x" }, "aQ", "a'")
-- utils.map({ "o", "x" }, "ic", "i}") -- [c]urly brackets
-- utils.map({ "o", "x" }, "ac", "a}")
-- utils.map({ "o", "x" }, "iB", "i]") -- rectangular [B]rackets
-- utils.map({ "o", "x" }, "aB", "a]")
-- utils.map({ "o", "x" }, "ir", "i]") -- [r]ectangular brackets
-- utils.map({ "o", "x" }, "ar", "a]")
-- utils.map({ "o", "x" }, "ib", "i)") -- [b]rackets
-- utils.map({ "o", "x" }, "ab", "a)")
-- utils.map({ "o", "x" }, "ia", "i>") -- [a]ngle brackets
-- utils.map({ "o", "x" }, "aa", "a>")
