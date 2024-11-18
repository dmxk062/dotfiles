local M = {
    "rafcamlet/tabline-framework.nvim",
}

local user = os.getenv("USER")

_G.Bufs_for_idx = {}

---@param fname string?
---@param bname string
---@param id integer
---@return string
---@return boolean
local function get_buf_title(fname, bname, id)
    local term_title = vim.b[id].term_title
    if term_title then
        return term_title, false
    end

    if fname then
        return fname, true
    end

    local ft = vim.bo[id].filetype
    if ft == "oil" then
        if vim.startswith(bname, "oil-ssh://") then
            local _, _, host, path = bname:find("//([^/]+)/(.*)")
            return host .. ":" .. path, true
        else
            local n = bname:sub(#"oil://" + 1)
                :gsub("/tmp/workspaces_" .. user, "~tmp")
                :gsub("/home/" .. user .. "/ws", "~ws")
                :gsub("/home/" .. user .. "/.config", "~cfg")
                :gsub("/home/" .. user, "~")
            if #n > 1 then
                return n:sub(1, -2), true
            else
                return n, true
            end
        end
    end

    if bname == "" then
        return "[-]", true
    end

    return bname, true
end

---@class bufinfo
---@field index integer
---@field buf integer
---@field buf_nr integer
---@field buf_name string
---@field filename string?
---@field modified boolean
---@field current boolean
---@field before_current boolean
---@field after_current boolean
---@field first boolean
---@field last boolean

local theme = require("theme.colors")
local col = theme.colors
local pal = theme.palettes.dark

local hl = {
    inactive = { bg = pal.bg1, fg = pal.fg2 },
    active = { bg = col.teal, fg = pal.bg0 },
}

local delims = {
    inactive = {
        l = { "", fg = pal.bg1, bg = pal.bg0 },
        r = { "", fg = pal.bg1, bg = pal.bg0 },
    },
    active = {
        l = { "", fg = col.teal, bg = pal.bg0 },
        r = { "", fg = col.teal, bg = pal.bg0 },
    }
}


local function render_tabline(f)
    local wins = vim.api.nvim_list_wins()

    local buf_wincounts = {}
    for _, win in pairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        buf_wincounts[buf] = (buf_wincounts[buf] or 0) + 1
    end

    ---@param info bufinfo
    f.make_bufs(function(info)
        Bufs_for_idx[info.index] = info.buf_nr
        local index = info.current and "active" or "inactive"

        f.add(delims[index].l)
        f.set_colors(hl[index])
        if info.current then
            f.set_gui("bold")
        end

        local title, show_modified = get_buf_title(info.filename, info.buf_name, info.buf_nr)
        if not buf_wincounts[info.buf_nr] then
            f.add(".")
        end
        f.add((info.current and "" or info.index) .. " " .. title)

        if show_modified and info.modified then
            f.add(" [+]")
        end

        f.add(delims[index].r)
        f.set_colors { fg = pal.bg0, bg = pal.bg0 }
        f.add(" ")
    end)

    f.add_spacer()

    f.make_tabs(function(info)
        -- don't show only tab
        if info.first and info.last then
            return
        end
        f.add(" ")
        local index = info.current and "active" or "inactive"

        f.add(delims[index].l)
        f.set_colors(hl[index])
        if info.current then
            f.set_gui("bold")
        end

        f.add(info.current and "" or tostring(info.tab))

        if info.modified then
            f.add(" [+]")
        end

        f.add(delims[index].r)
        f.set_colors { fg = pal.bg0, bg = pal.bg0 }
    end)
end


M.config = function()
    vim.o.showtabline = 2
    require("tabline_framework").setup {
        render = render_tabline
    }
end

return M
