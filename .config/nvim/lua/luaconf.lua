require('bar')

require('completion')

require('fold')

require('telesc')
-- require('tabline')

require("toggleterm").setup{
    shade_terminals = false,
    highlights = {
        Normal = {
          guibg = "none",
          guicursor ="hor20"
        },
        NormalFloat = {
          guibg = "none",
        },
        FloatBorder = {
          guibg = "none",
        },
      },
}

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

local comment = require('Comment')
local ft = require("Comment.ft")
ft.hyprlang = {"#%s"}
comment.setup()

require('leap').add_default_mappings()

require("closeconf")

require("treesitter")

require("lsp")
require("latex")

