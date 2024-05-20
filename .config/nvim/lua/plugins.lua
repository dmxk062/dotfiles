local utils = require("utils")


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

local comment = require('Comment')
local ft = require("Comment.ft")
ft.hyprlang = {"#%s"}
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

-- idk, i wish that was buffer local tbh
vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function() 
        local buftype = vim.api.nvim_buf_get_option(0, "filetype")
        if buftype == "TelescopePrompt" or buftype == "alpha" or buftype == "Oil" then
            vim.wo.cursorlineopt = "line,number"
        else
            vim.wo.cursorlineopt = "number"
        end
    end
})
