return {
    "ggandor/leap.nvim",
    config = function()
        local utils = require("utils")
        utils.map("n", "S", "<Plug>(leap-from-window)")
        utils.map("n", "s", "<Plug>(leap)")
    end,
    dependencies = {
        "ggandor/leap-spooky.nvim",
        config = function()
            require("leap-spooky").setup {
                -- same ones as in treesitter
                extra_text_objects = {
                    "if", "af",           -- functions
                    "aA", "ia", "aa",     -- function args
                    "vv", "vn",           -- assignment
                    "ic", "ac",           -- comments
                    "iL", "aL",           -- loops
                    "iC", "aC",           -- classes, structs
                    "ii", "ai",           -- conditionals
                },
            }
        end
    }
}
