local colors = require("nord.named_colors")


local active_hl = {
    fill = {
        bg = colors.black,
    }, 
    body = { 
        fg = colors.black, 
        bg = colors.teal,
        style = "bold"
    },
    sep = { 
        bg = colors.teal, 
        fg = colors.black
    }
}
local inactive_hl = {
    fill = {
        bg = colors.black,
    }, 
    body = { 
        fg = colors.white, 
        bg = colors.light_gray,
    },
    sep = { 
        bg = colors.light_gray, 
        fg = colors.white
    }
}

require('tabby.tabline').set(function(line)
    return {
        line.tabs().foreach(function(tab)
            local hl = tab.is_current() and active_hl or inactive_hl
            return {
                line.sep('', hl.sep, hl.fill),
                tab.is_current() and '' or tab.number(),
                tab.name(),
                tab.close_btn('󰅖'),
                line.sep(' ', hl.sep, hl.fill),
                hl = hl.body,
                margin = ' ',
            }
        end),
    }
end)
