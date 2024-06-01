-- lualine and tabline_framework
require('statusbar')
require('tabbar')

-- nvim-cmp
require('completion')

-- folds
require('fold')



require("colorizer").setup {
    filetypes = { "*" },
    user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        AARRGGBB = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        tailwind = false,
        sass = { enable = false, parsers = { "css" }, },
        virtualtext = "",
        always_update = false
    },
    buftypes = {},
}

-- mainly for lsp rename
require("dressing").setup {
    input = {
        insert_only = false,
        default_prompt = "Input",
        trim_prompt = false,
    },
    select = {
        enabled = false,
    },
}

local comment = require('Comment')
local ft = require("Comment.ft")
ft.hyprlang = { "#%s" }
comment.setup()

-- brackets etc
require("surround")

-- basic treesitter
require("treesitter")

-- lspconfig
require("lsp")

-- leap.nvim
require("jump")

-- telescope
require('telesc')

-- utils for those two
require("latex")
require("markdown")

-- oil.nvim
require("filemanager")

-- gitsigns
require("git")

-- startup
require("startscreen")
