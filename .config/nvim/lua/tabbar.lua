local colors = require("nord.named_colors")



hl_active = {
    body = {
        fg = colors.black,
        bg = colors.teal
    },
    add = {
        fg = colors.white,
        bg = colors.light_gray,
    },
    delim = {
        fg = colors.teal,
        bg = colors.black
    }
}
hl_inactive = {
    body = {
        fg = colors.white,
        bg = colors.light_gray
    },
    add = {
        fg = colors.white,
        bg = colors.dark_gray,
    },
    delim = {
        fg = colors.light_gray,
        bg = colors.black
    }
}

local function render(f) 
    f.make_tabs(function(info)
        local hl = (info.current and hl_active or hl_inactive)

        f.add{"", fg = hl.delim.fg, bg = hl.delim.bg}
        f.set_colors{fg = hl.body.fg, bg = hl.body.bg}
        f.add{(info.current and "" or info.index) .. " " .. (info.filename or "[No Name]")}
        f.add(info.modified and " [+]")
        if not (info.first and info.last) then
            f.close_tab_btn{" 󰅖"}
        end
        f.add{"", fg = hl.delim.fg, bg = hl.delim.bg}  
        f.set_colors{fg = colors.black, bg = colors.black}
        f.add(" ")

    end)
    f.add_spacer()
    f.add{"", fg = hl_inactive.delim.fg, bg = hl_inactive.delim.bg}
    f.set_colors{fg = hl_inactive.body.fg, bg = hl_inactive.body.bg}
    f.add_btn({"󰝜 New Tab"}, function(data)
        vim.api.nvim_command("tabnew")
    end)
    f.add{"", fg = hl_inactive.delim.fg, bg = hl_inactive.delim.bg}  
    f.set_colors{fg = colors.black, bg = colors.black}


end

require("tabline_framework").setup {
    hl_fill = {bg = colors.black, fg = colors.black},
    hl = {bg = colors.black, fg = colors.black},
    render = render,
}
