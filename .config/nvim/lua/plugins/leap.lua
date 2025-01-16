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
    utils.map("o", "r", function() require("leap.remote").action() end)

    -- use from normal mode: e.g. gR<leap>dd
    utils.map("n", "gR", function() require("leap.remote").action() end)

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
