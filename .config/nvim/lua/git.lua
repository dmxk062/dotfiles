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
}
