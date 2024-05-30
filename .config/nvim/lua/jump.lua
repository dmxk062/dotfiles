local leap = require("leap")
local spooky = require("leap-spooky")
local utils = require("utils")

utils.map("n", "s", "<Plug>(leap)")
utils.map("n", "S", "<Plug>(leap-from-window)")
utils.map({"x", "o"}, "S", "<Plug>(leap-forward)")

spooky.setup {
    -- same ones as in treesitter
    extra_text_objects = {
        "if", "af", -- functions
        "aA", "ia", "aa", -- function args
        "vv", -- assignment
        "ic", "ac", -- comments
        "iL", "aL", -- loops
    },
}
