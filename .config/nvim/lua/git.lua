local gitsigns = require("gitsigns")

gitsigns.setup {
    signs = {
        add         = { text = "+"},
        change      = { text = "~"},
        delete      = { text = "-"},
        topdelete   = { text = "-"},
        changedelete= { text = "~"},
        untracked   = { text = "."},
    },

    preview_config = {
        border = "rounded",
    },

    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'right_align',
        delay = 200,
    },

    on_attach = function()
        local utils = require("utils")
        local prefix = "<space>g"

        utils.lmap(bufnr, "n", prefix .. "t", gitsigns.toggle_signs)
        utils.lmap(bufnr, "n", prefix .. "d", gitsigns.diffthis)
        utils.lmap(bufnr, "n", prefix .. "D", function() gitsigns.diffthis("~") end)
        utils.lmap(bufnr, "n", prefix .. "b", gitsigns.blame_line)
        utils.lmap(bufnr, "n", prefix .. "B", gitsigns.toggle_current_line_blame)

        utils.lmap(bufnr, "n", prefix .. "w", gitsigns.toggle_word_diff)
        utils.lmap(bufnr, "n", prefix .. "r", gitsigns.toggle_deleted)
    end,
}
