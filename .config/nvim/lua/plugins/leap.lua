local M = {
    "ggandor/leap.nvim",
}

--[[ Rationale {{{
Why leap? Aren't motions enough?

Yes, that's why i mostly use leap for it's remote functionality
This allows me to use it to augment built in textobjects

The standalone leap in normal mode can still be useful,
*if* I am just navigating inside a single screen of text
Otherwise, search or various more powerful (and easier) motions
are much much easier
}}} ]]--

M.config = function()
    local utils = require("config.utils")
    local map = utils.map

    map("n", "S", "<Plug>(leap-from-window)")
    map("n", "s", "<Plug>(leap)")

    -- much more flexible than leap-spooky, no more need for mapping every object, this allows motions
    -- format is different: <op>r<leap><motion/textobject>
    -- e.g. crle<cr>i"<esc>
    -- repeat the operator for line: crle<cr>c<esc>
    -- not for visual mode, since r is useful there
    map("o", "r", function() require("leap.remote").action() end)

    -- HACK: override colors only after it has been setup
    vim.api.nvim_create_autocmd("User", {
        pattern = "LeapEnter",
        once = true,
        callback = function()
            local theme = require("theme.colors")
            vim.api.nvim_set_hl(0, "LeapLabelDimmed", {
                bg = theme.palettes.default.bg3,
                nocombine = true,
            })
        end
    })


    -- additionally, for textobjects just
    -- d<a,i>r<thing> works too
    -- easier to remember, more vim
    local textobjects_ai = {
        -- builtins
        "w", "W", "p",
        -- delimiters
        "[", "]", "(", ")", "{", "}", "'", '"', "`", "<", ">", "b", "t", "q", "Q", "B",
        -- treesitter
        "f", "a", "c", "l", "s", "?", "<space>",
        -- my own
        "i", "o", "-", ".", "/", "z"
    }

    -- not full pairs
    local textobjects_full = {
        -- treesitter
        "iv", "aA", "iN", "in",
        -- my own
        "id", "iDe", "iDw", "iDi", "iDh", "aI", "gG"
    }

    for _, obj in ipairs(textobjects_ai) do
        map({ "x", "o" }, "ir" .. obj, function()
            require("leap.remote").action { input = "i" .. obj }
        end)
        map({ "x", "o" }, "ar" .. obj, function()
            require("leap.remote").action { input = "a" .. obj }
        end)
    end

    for _, obj in ipairs(textobjects_full) do
        local scope = obj:sub(1, 1)

        map({ "x", "o" }, scope .. "r" .. obj:sub(2), function()
            require("leap.remote").action { input =  obj }
        end)
    end
end

return M
