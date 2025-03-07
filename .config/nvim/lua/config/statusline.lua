local M = {}
local api = vim.api
local augroup = api.nvim_create_augroup("statusline", { clear = true })
local utils = require("config.utils")
local format_buf_name = utils.format_buf_name
local btypehighlights, btypesymbols = utils.btypehighlights, utils.btypesymbols

-- my own statusline
-- this should be faster than lualine
-- generally, only redraw things using autocmds unless there isnt a good one for the event

local function padd(str, len)
    local strlen = #str
    if strlen >= len then
        return str
    else
        local diff = len - strlen
        if diff > 1 then
            return (" "):rep(math.floor(len / 2)) .. str .. (" "):rep(math.floor(len / 2))
        else
            return str .. " "
        end
    end
end


local mode_to_hl_group = {
    ---@format disable
    n      = "Normal",
    i      = "Insert",
    c      = "Command",
    v      = "Visual",
    V      = "Visual",
    [""] = "Visual",
    [""] = "Visual",
    ["S"]  = "Visual",
    s      = "Visual",
    t      = "Normal",
    R      = "Replace",
    r      = "Command",
    ["!"]  = "Command",
    ---@format enabled
}

local mode_to_name = {
    ---@format disable
    ["n"]    = "n",
    ["no"]   = "o",
    ["nov"]  = "o",
    ["noV"]  = "O",
    ["no"] = "^O",

    ["v"]    = "v",
    ["V"]    = "V",
    [""]   = "^V",
    [""]   = "^S",

    ["R"]    = "r",
    ---@format enabled
}

local function update_mode()
    local has_multicursor = require("multicursor-nvim").hasCursors()
    local mode = api.nvim_get_mode().mode
    local short = mode:sub(1, 1)
    local hl = mode_to_hl_group[short]

    return string.format("%%#SlSMode%s#%%#SlMode%s#%s%%#SlSMode%s#",
        hl,
        hl,
        padd(((has_multicursor and "C-" or "") .. (mode_to_name[mode] or short)), 3),
        hl
    )
end


local function update_title()
    local buf = api.nvim_get_current_buf()
    local name, kind, show_modified = format_buf_name(buf)

    local changed = vim.bo[buf].modified
    local readonly = vim.bo[buf].readonly or not vim.bo[buf].modifiable

    return string.format(" %%#SlASL#%%#SlA%s#%s %%#SlAText#%s %s%s%%#SlASR#",
        btypehighlights[kind],
        btypesymbols[kind],
        (name or "[-]"),
        (readonly and show_modified and "%#SlAReadonly#[ro]" or ""),
        (show_modified and not readonly
            and (changed and "%#SlAChanged#~" or (" "))
            or "")
    )
end


local function update_diagnostics()
    local err, warn, hint, info = 0, 0, 0, 0
    local diags = vim.diagnostic.get(0)

    if not diags or #diags == 0 then
        return ""
    end

    local sev = vim.diagnostic.severity

    for _, diag in ipairs(diags) do
        if diag.severity == sev.ERROR then
            err = err + 1
        elseif diag.severity == sev.WARN then
            warn = warn + 1
        elseif diag.severity == sev.HINT then
            hint = hint + 1
        else
            info = info + 1
        end
    end
    local res = {}
    if err > 0 then
        table.insert(res, string.format("%%#SlError#e:%d", err))
    end
    if warn > 0 then
        table.insert(res, string.format("%%#SlWarning#w:%d", warn))
    end
    if hint > 0 then
        table.insert(res, string.format("%%#SlHint#h:%d", hint))
    end
    if info > 0 then
        table.insert(res, string.format("%%#SlInfo#i:%d", info))
    end

    return " %#SlASL#" .. table.concat(res, " ") .. "%#SlASR#"
end

local function update_macro(ev)
    if ev == "RecordingLeave" then
        local last = vim.fn.reg_recording()
        if last == "" then
            return ""
        end

        return " %#SlASL#" .. '%#SlRegister#@' .. last .. "%#SlASR#"
    else
        local reg = vim.fn.reg_recording()
        return " %#SlASL#" .. '%#SlRegister#"' .. reg .. " <-%#SlASR#"
    end
end


local function update_diffs()
    if not vim.b[0].gitsigns_status_dict then
        return ""
    end
    local status = vim.b[0].gitsigns_status_dict

    local res = {}
    if status.added and status.added > 0 then
        table.insert(res, string.format("%%#SlDiffAdded#+%d", status.added))
    end
    if status.changed and status.changed > 0 then
        table.insert(res, string.format("%%#SlDiffChanged#~%d", status.changed))
    end
    if status.removed and status.removed > 0 then
        table.insert(res, string.format("%%#SlDiffRemoved#-%d", status.removed))
    end
    if #res == 0 then
        return ""
    end

    return " %#SlASL#" .. table.concat(res, " ") .. "%#SlASR#"
end

local function update_filetype()
    local ft = vim.bo[0].filetype
    if ft and ft ~= "" then
        return ft
    else
        return "[noft]"
    end
end

local function update_wordcount()
    local wc = vim.fn.wordcount()
    if wc.visual_words then
        return string.format(" w:%d c:%d", wc.visual_words, wc.visual_chars)
    else
        return " w:" .. wc.words
    end
end

-- set up the gradient
local theme = require("theme.colors")
for i = 0, 10 do
    local bg = theme.blend(theme.colors.pink, theme.colors.teal, (i / 10))
    local fg = theme.palettes.default.inverted
    vim.api.nvim_set_hl(0, "SlProgress" .. i, {
        bg = bg,
        fg = fg,
    })
    vim.api.nvim_set_hl(0, "SlSProgress" .. i, {
        fg = bg,
        bg = theme.palettes.default.bg0,
    })
end

local function update_progress()
    local row = api.nvim_win_get_cursor(0)[1]
    local num_lines = api.nvim_buf_line_count(0)
    local progress = row / num_lines
    local as_int = math.floor(progress * 10)

    local text
    if row == 1 then
        text = "Top"
    elseif row == num_lines then
        text = "End"
    else
        text = string.format("%02d%%%%", progress * 100)
    end

    return string.format("%%#SlSProgress%d#%%#SlProgress%d#%s : %d%%#SlSProgress%d#",
        as_int, as_int,
        text,
        num_lines,
        as_int
    )
end

local sections
local redraw = function()
    vim.o.statusline = table.concat(sections)
end

local indices = {
    mode = 1,
    title = 2,
    diagnostics = 3,
    macro = 4,
    diffs = 6,
    filetype = 8,
    wordcount = 9,
    progress = 11,
}

api.nvim_create_autocmd({ "ModeChanged" }, {
    group = augroup,
    callback = function(ev)
        -- stop flickering
        if vim.bo[ev.buf].filetype == "TelescopePrompt" then
            return
        end
        sections[indices.mode] = update_mode()
        redraw()
    end
})

api.nvim_create_autocmd({ "BufEnter", "BufLeave", "WinEnter", "BufModifiedSet", "FileChangedRO", "TermRequest" }, {
    group = augroup,
    callback = vim.schedule_wrap(function()
        sections[indices.title] = update_title()
        redraw()
    end)
})

api.nvim_create_autocmd({ "BufEnter", "FileType", "BufLeave" }, {
    group = augroup,
    callback = vim.schedule_wrap(function()
        -- prevent completion etc
        if api.nvim_get_mode().mode:sub(1, 1) ~= "n" then
            return
        end
        sections[indices.filetype] = update_filetype()
        redraw()
    end)
})

api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
    group = augroup,
    callback = function(ev)
        sections[indices.macro] = update_macro(ev.event)
        redraw()
    end
})

local always_timer = vim.uv.new_timer()
always_timer:start(0, 100, vim.schedule_wrap(function()
    sections[indices.wordcount] = update_wordcount()
    sections[indices.progress] = update_progress()
    redraw()
end))

-- only updates in normal mode
local normal_timer = vim.uv.new_timer()
normal_timer:start(0, 100, vim.schedule_wrap(function()
    if api.nvim_get_mode().mode:sub(1, 1) ~= "n" then
        return
    end
    sections[indices.diagnostics] = update_diagnostics()
    sections[indices.diffs] = update_diffs()
    redraw()
end)
)



-- prefill the line
-- some will be static, some only updated via autocmd, some via timer
sections = {
    update_mode(),           -- mode
    update_title(),          -- title of buf with modified etc
    "",                      -- diagnostics
    "",                      -- macro
    " %#SlKeys#%-3(%S%)%= %#SlRow#%3l%#Delimiter#:%#SlCol#%-3c %=", -- keys, position and right align
    "",                      -- diff
    " %#SlASL#%#SlAText#",
    "",                      -- filetype
    "",                      -- wordcount
    "%#SlASR# ",
    update_progress(),       -- % in file
}

vim.o.laststatus = 3
vim.o.showcmdloc = "statusline"

redraw()


return M
