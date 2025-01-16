local M = {
    "rafcamlet/tabline-framework.nvim",
}

-- mapping of buffer indices in the buffer line to buffer numbers
---@type table<integer, integer>
_G.Bufs_for_idx = {}
-- mapping of tab indices in the buffer line to tab ids
---@type table<integer, integer>
_G.Tabs_for_idx = {}

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
local pal = theme.palettes.default

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
        local type = info.current and "active" or "inactive"
        local bufnr = info.buf_nr
        local wincount = buf_wincounts[bufnr] or 0
        Bufs_for_idx[info.index] = bufnr

        f.add(delims[type].l)
        f.set_colors(hl[type])
        if info.current then
            f.set_gui("bold")
        end

        local title, show_modified = require("plugin_utils.bufs").format_buf_name(info.buf, true)
        if wincount == 0 then
            f.add(".")
        end

        f.add(info.index .. " " .. title)

        if show_modified and info.modified then
            f.add(" [+]")
        end

        if wincount > 1 then
            f.add(" {" .. wincount .. "}")
        end

        f.add(delims[type].r)
        f.set_colors { fg = pal.bg0, bg = pal.bg0 }
        f.add(" ")
    end)

    f.add_spacer()

    local tab_wincounts = {}
    for _, page in pairs(vim.api.nvim_list_tabpages()) do
        tab_wincounts[page] = #vim.api.nvim_tabpage_list_wins(page)
    end

    f.make_tabs(function(info)
        Tabs_for_idx[info.index] = info.tab
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

        f.add(tostring(info.index))
        f.add(" {" .. tab_wincounts[info.tab] .. "}")

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
