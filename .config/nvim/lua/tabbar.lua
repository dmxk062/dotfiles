local colors = require("nord.named_colors")
local util = require('tabby.util')


local function format_tab(tabid, active)
    local number = vim.api.nvim_tabpage_get_number(tabid)
    local name = util.get_tab_name(tabid)
    if active then
        return " " .. name
    else 
        return string.format("%d %s", number, name)
    end
end

local format = {
    layout = "tab_only",
    hl = {fg = colors.black, bg = colors.black},

    active_tab = {
        label = function(tabid)
            return {
                format_tab(tabid, true),
                hl = {fg = colors.black, bg = colors.teal, gui = "bold"}
            }
        end,
        left_sep = {"", hl = {fg = colors.teal}},
        right_sep = {"", hl = {fg = colors.teal}},
    },

    inactive_tab = {
        label = function(tabid)
            return {
                format_tab(tabid, false),
                hl = {fg = colors.white, bg = colors.light_gray}
            }
        end,
        left_sep = {"", hl = {fg = colors.light_gray}},
        right_sep = {"", hl = {fg = colors.light_gray}},
    }

}

require("tabby").setup({
    tabline = format
})
