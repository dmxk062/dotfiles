local bufferline = require("bufferline")

bufferline.setup{
    highlights = {
        fill = {
            bg = {
            }
        },
        background = {
            bg = {
            }
        },
        tab = {
            bg = ""
        }
    },
    options = {
        mode = "tabs",
        themable = true,
        indicator = {
            style = 'none'
        },
        modified_icon = '[+]',
        close_icon = '󰅖',
        left_trunc_marker = '~',
        right_trunc_marker = '...',
        get_element_icon = function(element) 
            return ""
        end
    }
}
