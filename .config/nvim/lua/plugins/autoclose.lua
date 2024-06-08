return {
    "m4xshen/autoclose.nvim",
    event = { "InsertEnter" },
    config = function()
        require("autoclose").setup({
            keys = {
                ["("] = { escape = false, close = true, pair = "()" },
                ["["] = { escape = false, close = true, pair = "[]" },
                ["{"] = { escape = false, close = true, pair = "{}" },

                [")"] = { escape = true, close = false, pair = "()" },
                ["]"] = { escape = true, close = false, pair = "[]" },
                ["}"] = { escape = true, close = false, pair = "{}" },

                ['"'] = { escape = true, close = true, pair = '""' },
                ["'"] = { escape = true, close = true, pair = "''" },
                ["`"] = { escape = true, close = true, pair = "``" },
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
    end
}
