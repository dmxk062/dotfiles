-- local ai_textobjects = {
--     "w", "W", "p", "s", "b", "B",           -- words
--     "[", "]", "(", ")", "{", "}", "<", ">", -- punctuation
--     "`", "'", '"',                          -- quotes
--     "a", "f", "c", "L", "C", "R",           -- treesitter
--     "i", "n"                                -- my own indent and numbers
-- }


local M = {
    "ggandor/leap.nvim",
}
M.config = function()
    local utils = require("utils")
    utils.map("n", "S", "<Plug>(leap-from-window)")
    utils.map("n", "s", "<Plug>(leap)")

    -- much more flexible than leap-spooky, no more need for mapping every object, this allows motions
    -- format is different: <op>r<leap><motion/textobject>
    -- e.g. crle<cr>i"<esc>
    -- repeat the operator for line: crle<cr>c<esc>
    -- not for visual mode, since r is useful there
    utils.map({ "o" }, "r", function() require("leap.remote").action() end)

    -- use from normal mode: e.g. gR<leap>dd
    utils.map("n", "gR", function() require("leap.remote").action() end)

    -- -- but i can't fully live without my textobjects:
    -- -- those work like the old leap-spooky ones:
    -- -- <op>{a,i}r{obj}<leap>
    -- for _, obj in pairs(ai_textobjects) do
    --     utils.map({ "x", "o" }, "a" .. "r" .. obj, function()
    --         require("leap.remote").action { input = "a" .. obj }
    --     end)
    --     utils.map({ "x", "o" }, "i" .. "r" .. obj, function()
    --         require("leap.remote").action { input = "i" .. obj }
    --     end)
    -- end
end

return M
