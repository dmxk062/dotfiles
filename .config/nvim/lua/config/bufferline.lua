local api = vim.api
local fn = vim.fn
local augroup = api.nvim_create_augroup("bufferline", { clear = true })
local utils = require("config.utils")
local getbufname = utils.format_buf_name
local btypehighlights, btypesymbols = utils.btypehighlights, utils.btypesymbols

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
        local hlprefix = current and "SlA" or "SlI"
        local changed = vim.bo[b].modified
        local readonly = vim.bo[b].readonly or not vim.bo[b].modifiable

        local res = string.format("%s%%#%s#%s%d %%#%s#%s %s%s%s",
            current and "%#SlASL#" or (count > 1 and "%#SlASL#|" or " "),
            hlprefix .. btypehighlights[kind],
            btypesymbols[kind],
            count,
            hlprefix .. (wincount == 0 and "Hidden" or "Text"),
            (name or "[-]"),
            (readonly and "%#" .. hlprefix .. "Readonly#[ro]" or ""),
            (show_modified and not readonly
                and (changed and "%#" .. hlprefix .. "Changed#~" or " ")
                or ""),
            current and "%#SlASR#" or " "
        )
        table.insert(out, res)

        Bufs_for_idx[count] = b
        idx_for_buf[b] = count
        count = count + 1

        ::continue::
    end
    out[#out + 1] = "%#SlReset# "

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
        local hlprefix = current and "SlA" or "SlI"

        local bufs_shown = {}
        for _, w in pairs(api.nvim_tabpage_list_wins(t)) do
            local buf = idx_for_buf[api.nvim_win_get_buf(w)]
            if buf then
                bufs_shown[buf] = true
            end
        end
        local shown_bufs = vim.tbl_keys(bufs_shown)

        local ret = string.format("%s%%#%s#%d%%#%s#|%%#%s#%s%s",
            current and "%#SlASL#" or (count > 1 and "%#SlASL#|" or " "),
            hlprefix .. "Tab",
            count,
            hlprefix .. "Hidden",
            hlprefix .. "Text",
            table.concat(shown_bufs, " "),
            current and "%#SlASR#" or " "
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
