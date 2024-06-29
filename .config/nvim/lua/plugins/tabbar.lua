local M = {
    "rafcamlet/tabline-framework.nvim",
}

local theme = require("theme.colors")
local pal = theme.palettes.dark
local col = theme.colors
local hl_active = {
    body = {
        fg = pal.bg0,
        bg = col.teal
    },
    add = {
        fg = pal.fg0,
        bg = pal.bg3,
    },
    delim = {
        fg = col.teal,
        bg = pal.bg0
    },
    mod = {
        fg = pal.fg0,
        bg = pal.bg3,
    }
}
local hl_inactive = {
    body = {
        fg = pal.fg0,
        bg = pal.bg3
    },
    add = {
        fg = pal.fg0,
        bg = pal.bg1,
    },
    delim = {
        fg = pal.bg3,
        bg = pal.bg0
    },
    mod = {
        fg = pal.fg0,
        bg = pal.bg1,
    }
}

local delims = {
    left  = "",
    right = "",
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
                    name = name:sub(1, -2) -- remove final '/' if its not /
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

        f.add { delims.left, fg = hl.delim.fg, bg = hl.delim.bg }
        f.set_colors { fg = hl.body.fg, bg = hl.body.bg }
        if info.current then
            f.set_gui("bold")
        end
        local title, show_modified = get_buf_info(info.filename, info.buf_name, info.buf)
        f.add { (info.current and "" or info.index) .. " " .. title }
        if not (info.first and info.last) then
            f.close_tab_btn { " 󰅖" }
        end
        if show_modified and info.modified then
            f.set_gui("none")
            f.add { delims.right, fg = hl.delim.fg, bg = hl.mod.bg }
            f.add { " ~", fg = hl.mod.fg, bg = hl.mod.bg }
            f.add { delims.right, fg = hl.mod.bg, bg = pal.bg0 }
        else
            f.add { delims.right, fg = hl.delim.fg, bg = hl.delim.bg }
        end
        f.set_colors { fg = pal.bg0, bg = pal.bg0 }
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
                    f.add { " .. ", fg = col.light_gray, bg = pal.bg0 }
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
        hl_fill = { bg = pal.bg0, fg = pal.bg0 },
        hl = { bg = pal.bg0, fg = pal.bg0 },
        render = render,
    }
end

return M
