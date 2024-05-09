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

local new_tab_width = 12

local USER = os.getenv("USER")

local function starts_with(str, prefix) 
    return str:sub(1, #prefix) == prefix
end

local function get_buf_name(filename, bufname, bufid) 
    local name = ""
    if filename then
        name = filename
    elseif not bufname or bufname == "" then
        name = "[No Name]"
    elseif starts_with(bufname, "oil://") then
        local ret = bufname:sub(#"oil://" + 1)
        ret = ret:gsub("/home/" .. USER .. "/ws", "~ws") 
        name = ret:gsub("/home/" .. USER, "~"):sub(1, -2)
    end

    return name

end

local function draw_tab(f, info) 
    local hl = (info.current and hl_active or hl_inactive)

    f.add{"", fg = hl.delim.fg, bg = hl.delim.bg}
    f.set_colors{fg = hl.body.fg, bg = hl.body.bg}
    if info.current then
        f.set_gui("bold")
    end
    local bufname = get_buf_name(info.filename, info.buf_name, info.buf)
    f.add{(info.current and "" or info.index) .. " " ..  bufname}
    f.add(info.modified and " [+]")
    if not (info.first and info.last) then
        f.close_tab_btn{" 󰅖"}
    end
    f.add{"", fg = hl.delim.fg, bg = hl.delim.bg}  
    f.set_colors{fg = colors.black, bg = colors.black}
    f.add(" ")
end

local function render_num(f, active, num)
    local start = active - ((num - 1) /2)
    local endi = active + ((num - 1) /2)
    if start < 0 then
        start = 0
    end
    local i = 0
    f.make_tabs(function(info)
        if i <= endi and i >= start then
            draw_tab(f, info)
        else if i == (endi + 1) or i == (start - 1) then
                f.add{" .. ", fg = colors.light_gray, bg = colors.black}
            end
        end
        i = i+1
    end)
end

local function new_tab_button(f) 
    f.add{"", fg = hl_inactive.delim.fg, bg = hl_inactive.delim.bg}
    f.set_colors{fg = hl_inactive.body.fg, bg = hl_inactive.body.bg}
    f.add_btn({"󰝜 New Tab"}, function(data)
        vim.api.nvim_command("tabnew")
    end)
    f.add{"", fg = hl_inactive.delim.fg, bg = hl_inactive.delim.bg}  
    f.set_colors{fg = colors.black, bg = colors.black}
end

local function render(f) 
    local width = vim.fn.winwidth(0)
    local num_tabs = 0
    local active_index = 0
    f.make_tabs(function(info)
        num_tabs = num_tabs + 1
        if info.current then
            active_index = info.index
        end
    end)
    -- local target_tabs = math.floor((width - new_tab_width) / 16)
    local target_tabs = math.floor(width  / 16)
    if target_tabs % 2 == 0 then
        target_tabs = target_tabs - 1
    end
    if num_tabs > target_tabs then
        render_num(f, active_index, target_tabs)
    else
        f.make_tabs(function(info)
            draw_tab(f, info)
        end)
    end
    -- f.add_spacer()
    -- new_tab_button(f)
end


require("tabline_framework").setup {
    hl_fill = {bg = colors.black, fg = colors.black},
    hl = {bg = colors.black, fg = colors.black},
    render = render,
}
