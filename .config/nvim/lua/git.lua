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
        virt_text_pos = 'eol',
        delay = 400,
    },

    on_attach = function(bufnr)
        local utils = require("utils")
        local git_prefix = "<space>g"
        -- utils.map("n", git_prefix .. "t", gitsigns.toggle_signs)
        utils.lmap(bufnr, "n", git_prefix .. "t", gitsigns.toggle_signs)

    end,

}

