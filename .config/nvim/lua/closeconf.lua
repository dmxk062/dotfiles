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


-- require"surround".setup {
--     context_offset = 100,
--     load_autogroups = false,
--     mappings_style = "sandwich",
--     map_insert_mode = true,
--     quotes = {"'", '"'},
--     brackets = {"(", '{', '[', '<'},
--     space_on_closing_char = false,
--     pairs = {
--         nestable = { 
--             b = { "(", ")" }, -- Braces
--             B = { "[", "]" }, -- Brackets
--             c = { "{", "}" }, -- Curly braces
--             a = { "<", ">" }, -- Angle brackets
--             s = { "$(", ")"}, -- Shell
--             v = { "${", "}" } -- Shell variable
--         },
--         linear = { 
--             Q = { "'", "'" }, -- Quote
--             t = { "`", "`" }, -- tick
--             T = { "```\n", "\n```" }, -- Triple ticks
--             q = { '"', '"' }, -- double quote
--             d = { "$", "$" }, -- dolar sign
--             D = { '"""\n', '\n"""' } -- docstring
--         },
--     },
--     prefix = "s"
-- }

require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })

-- this saves me from typing the special chars when i want to use them in motions
vim.keymap.set({ "o", "x" }, "iq", 'i"') -- [q]uote
vim.keymap.set({ "o", "x" }, "aq", 'a"')
vim.keymap.set({ "o", "x" }, "iQ", "i'") -- single [Q]uote
vim.keymap.set({ "o", "x" }, "aQ", "a'")
vim.keymap.set({ "o", "x" }, "ic", "i}") -- [c]urly brackets
vim.keymap.set({ "o", "x" }, "ac", "a}")
vim.keymap.set({ "o", "x" }, "iB", "i]") -- rectangular [B]rackets
vim.keymap.set({ "o", "x" }, "aB", "a]")
vim.keymap.set({ "o", "x" }, "ir", "i]") -- [r]ectangular brackets
vim.keymap.set({ "o", "x" }, "ar", "a]")
vim.keymap.set({ "o", "x" }, "ib", "i)") -- [b]rackets
vim.keymap.set({ "o", "x" }, "ab", "a)")
vim.keymap.set({ "o", "x" }, "ia", "i>") -- [a]ngle brackets
vim.keymap.set({ "o", "x" }, "aa", "a>")

