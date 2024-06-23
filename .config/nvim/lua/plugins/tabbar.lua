local M = {
    "rafcamlet/tabline-framework.nvim",
}

local colors = require("nord.colors")
local hl_active = {
    body = {
        fg = colors.nord0_gui,
        bg = colors.nord7_gui
    },
    add = {
        fg = colors.nord6_gui,
        bg = colors.nord3_gui,
    },
    delim = {
        fg = colors.nord7_gui,
        bg = colors.nord0_gui
    }
}
local hl_inactive = {
    body = {
        fg = colors.nord6_gui,
        bg = colors.nord3_gui
    },
    add = {
        fg = colors.nord6_gui,
        bg = colors.nord1_gui,
    },
    delim = {
        fg = colors.nord3_gui,
        bg = colors.nord0_gui
    }
}

local delims = {
    left  =  "",
    right =  "",
}

M.config = function()
    vim.o.showtabline = 2

    local user = os.getenv("USER")

    local function starts_with(str, prefix)
        return str:sub(1, #prefix) == prefix
    end

    local function get_buf_info(filename, bufname, bufid)
        local buftype = vim.bo[bufid]["filetype"]
        local name = ""
        local show_modified = true
        if filename then
            name = filename
        else
            if buftype == "TelescopePrompt" then
                name = "Telescope"
                show_modified = false
            elseif buftype == "DressingInput" then
                name = "Input"
                show_modified = false
            elseif buftype == "alpha" then
                show_modified = false
                name = "NeoVIM"
            elseif buftype == "oil" then
                if starts_with(bufname, "oil-ssh://") then
                    local addr = bufname:match("//(.-)/")
                    local path = bufname:match("//.-(/.*)"):sub(2, -1)
                    name = addr .. ":" .. path
                else
                    name = bufname:sub(#"oil://" + 1)
                        :gsub("/tmp/workspaces_" .. user, "~tmp")
                        :gsub("/home/" .. user .. "/ws", "~ws")
                        :gsub("/home/" .. user .. "/.config", "~cfg")
                        :gsub("/home/" .. user, "~")
                end
                if #name > 1 then
                    name = name:sub(1, -2)     -- remove final '/' if its not /
                end
            elseif bufname == "" then
                name = "[-]"
            else
                name = bufname
            end
        end

        return name, show_modified
    end

    local function draw_tab(f, info)
        local hl = (info.current and hl_active or hl_inactive)

        f.add {delims.left, fg = hl.delim.fg, bg = hl.delim.bg }
        f.set_colors { fg = hl.body.fg, bg = hl.body.bg }
        if info.current then
            f.set_gui("bold")
        end
        local title, show_modified = get_buf_info(info.filename, info.buf_name, info.buf)
        f.add { (info.current and "" or info.index) .. " " .. title }
        if show_modified then
            f.add(info.modified and " [+]")
        end
        if not (info.first and info.last) then
            f.close_tab_btn { " 󰅖" }
        end
        f.add {delims.right, fg = hl.delim.fg, bg = hl.delim.bg }
        f.set_colors { fg = colors.nord0_gui, bg = colors.nord0_gui }
        f.add(" ")
    end

    local function render_num(f, active, num)
        local start = active - ((num - 1) / 2)
        local endi = active + ((num - 1) / 2)
        if start < 0 then
            start = 0
        end
        local i = 0
        f.make_tabs(function(info)
            if i <= endi and i >= start then
                draw_tab(f, info)
            else
                if i == (endi + 1) or i == (start - 1) then
                    f.add { " .. ", fg = colors.light_gray, bg = colors.nord0_gui }
                end
            end
            i = i + 1
        end)
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
        local target_tabs = math.floor(width / 16)
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
    end


    require("tabline_framework").setup {
        hl_fill = { bg = colors.nord0_gui, fg = colors.nord0_gui },
        hl = { bg = colors.nord0_gui, fg = colors.nord0_gui },
        render = render,
    }
end

return M
