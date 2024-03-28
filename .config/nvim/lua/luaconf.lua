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
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue or blue
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = true, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        mode = "background", -- Set the display mode.
        tailwind = false, -- Enable tailwind colors
        sass = { enable = false, parsers = { "css" }, }, -- Enable sass colors
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
