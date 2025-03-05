local api = vim.api
local fn = vim.fn
local augroup = api.nvim_create_augroup("bufferline", { clear = true })
local getbufname = require("config.utils").format_buf_name

-- mapping of buffer indices in the buffer line to buffer numbers
---@type table<integer, integer>
_G.Bufs_for_idx = {}
-- mapping of tab indices in the buffer line to tab ids
---@type table<integer, integer>
_G.Tabs_for_idx = {}

local idx_for_buf = {}


local sections
local function redraw()
    vim.o.tabline = table.concat(sections)
end

local bufcmds = {
    "BufAdd",
    "BufDelete",
    "BufEnter",
    "BufFilePost",
    "BufHidden",
    "BufModifiedSet",
    "BufNew",
    "BufWinEnter",
    "BufWinLeave",
    "TermOpen",
    "TermRequest",
    "WinClosed",
    "WinEnter",
    "WinLeave",
}

local btypehighlights = {
    term = "Term",
    oil = "Dir",
    scratch = "Scratch",
    list = "List",
    git = "Git",
    reg = "Reg",
    empty = "Reg",
    special = "Special",
    help = "Help",
}

local btypesymbols = {
    term = "!",
    oil = ":",
    scratch = "&",
    list = "=",
    git = "@",
    reg = "#",
    empty = "#",
    special = "*",
    help = "?",
}

local function update_buflist()
    Bufs_for_idx = {}
    idx_for_buf = {}

    local count = 1
    local out = {}
    local active_buf = api.nvim_get_current_buf()
    local buffers = api.nvim_list_bufs()

    local windows = api.nvim_list_wins()
    local buf_wincounts = {}
    for _, win in pairs(windows) do
        local buf = api.nvim_win_get_buf(win)
        buf_wincounts[buf] = (buf_wincounts[buf] or 0) + 1
    end

    for _, b in ipairs(buffers) do
        local bo = vim.bo[b]

        if not bo.buflisted then
            goto continue
        end

        local current = b == active_buf
        local wincount = buf_wincounts[b] or 0
        local name, kind, show_modified = getbufname(b, true)
        local hlprefix = current and "BlA" or "BlI"
        local changed = vim.bo[b].modified
        local readonly = vim.bo[b].readonly or not vim.bo[b].modifiable

        local res = string.format("%s%%#%s#%s%d %%#%s#%s %s%s",
            current and "%#BlASL#" or (count > 1 and "%#BlASL#|" or " "),
            hlprefix .. btypehighlights[kind],
            btypesymbols[kind],
            count,
            hlprefix .. (wincount == 0 and "Hidden" or "Text"),
            (name or (readonly and "[ro]" or (changed and "[~]" or "[-]"))),
            ((show_modified and changed and name) and "%#" .. hlprefix .. "Changed#~" or " "),
            current and "%#BlASR#" or " "
        )
        table.insert(out, res)

        Bufs_for_idx[count] = b
        idx_for_buf[b] = count
        count = count + 1

        ::continue::
    end
    out[#out + 1] = "%#BlReset# "

    return table.concat(out)
end

local function update_tablist()
    Tabs_for_idx = {}
    local tabs = api.nvim_list_tabpages()
    if #tabs < 2 then
        return ""
    end
    local active_tab = api.nvim_get_current_tabpage()
    local count = 1

    local ret = vim.tbl_map(function(t)
        Tabs_for_idx[count] = t
        local current = active_tab == t
        local hlprefix = current and "BlA" or "BlI"

        local bufs_shown = {}
        for _, w in pairs(api.nvim_tabpage_list_wins(t)) do
            local buf = idx_for_buf[api.nvim_win_get_buf(w)]
            if buf then
                bufs_shown[buf] = true
            end
        end
        local shown_bufs = vim.tbl_keys(bufs_shown)

        local ret = string.format("%s%%#%s#%d%%#%s#|%%#%s#%s%s",
            current and "%#BlASL#" or (count > 1 and "%#BlASL#|" or " "),
            hlprefix .. "Tab",
            count,
            hlprefix .. "Hidden",
            hlprefix .. "Text",
            table.concat(shown_bufs, " "),
            current and "%#BlASR#" or " "
        )

        count = count + 1
        return ret
    end, tabs)

    return table.concat(ret)
end

api.nvim_create_autocmd(bufcmds, {
    group = augroup,
    callback = vim.schedule_wrap(function(ev)
        sections[1] = update_buflist()
        sections[3] = update_tablist()
        redraw()
    end)
})

sections = {
    "",
    "%=",
    update_tablist()
}

redraw()
vim.o.showtabline = 2
