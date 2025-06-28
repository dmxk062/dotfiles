---@type LazySpec
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
end

return M
