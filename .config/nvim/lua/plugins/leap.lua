local spooky = {
    "ggandor/leap-spooky.nvim",
    config = function()
        require("leap-spooky").setup {
            -- so i can use `r` for return statements
            prefix = true,
            -- same ones as in treesitter
            extra_text_objects = {
                "if", "af",                             -- functions
                "aA", "ia", "aa",                       -- function args
                "vv", "vn",                             -- assignment
                "ic", "ac",                             -- comments
                "iL", "aL",                             -- loops
                "iC", "aC",                             -- classes, structs
                "ii", "ai",                             -- conditionals
                "ir", "ar",                             -- return statements
                "i,", "a,", "i.", "a.", "i/", "a/",     -- custom things
                "in", "an",                             -- numbers
                "igh",                                  -- gitsigns hunk
                "idd", "ide", "idw", "idi", "idh",      -- lsp diagnostics
            },
        }
    end
}

local M = {
    "ggandor/leap.nvim",
    config = function()
        local utils = require("utils")
        utils.map("n", "S", "<Plug>(leap-from-window)")
        utils.map("n", "s", "<Plug>(leap)")
    end,
    dependencies = {spooky}
}

return M
