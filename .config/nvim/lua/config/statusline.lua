local M = {}
local api = vim.api
local augroup = api.nvim_create_augroup("statusline", { clear = true })

-- my own statusline
-- this should be faster than lualine
-- generally, only redraw things using autocmds unless there isnt a good one for the event

local function left_sep(hl)
    return "%#StatusLInv" .. hl .. "#"
end
local function right_sep(hl)
    return "%#StatusRInv" .. hl .. "#"
end

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
    return left_sep(hl) .. "%#Status" .. hl .. "#" 
        .. padd((has_multicursor and "C-" or "") .. (mode_to_name[mode] or short), 3)
        .. right_sep(hl)
end


local function update_title()
    local buf = api.nvim_get_current_buf()
    local name, kind, show_modified =  require("config.utils").format_buf_name(buf)

    if not show_modified then
        return name
    end
    local changed = vim.bo[buf].modified
    local readonly = vim.bo[buf].readonly or not vim.bo[buf].modifiable

    if not name then
        return readonly and "[ro]" or (changed and "[~]" or "[-]")
    end

    return name .. (readonly and " [ro]" or (changed and "~" or ""))
end


local function update_diagnostics()
    local err, warn, hint, info = 0, 0, 0, 0
    local diags = vim.diagnostic.get(0)

    if not diags then
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
    local res = { " " }
    if err > 0 then
        table.insert(res, string.format("%%#StatusError#e:%d ", err))
    end
    if warn > 0 then
        table.insert(res, string.format("%%#StatusWarning#w:%d ", warn))
    end
    if hint > 0 then
        table.insert(res, string.format("%%#StatusHint#h:%d ", hint))
    end
    if info > 0 then
        table.insert(res, string.format("%%#StatusInfo#i:%d ", info))
    end

    return table.concat(res)
end

local function update_macro(ev)
    if ev == "RecordingLeave" then
        local last = vim.fn.reg_recording()
        if last == "" then
            return ""
        end

        return '%#StatusRegister#"' .. last .. "%#StatusCenter#"
    else
        local reg = vim.fn.reg_recording()
        return '%#StatusRegister#"' .. reg .. "%#StatusCenter# <-"
    end
end

local function update_lsp_names()
    local clients = vim.lsp.get_clients { bufnr = 0 }
    if #clients == "" then
        return ""
    end

    local names = vim.tbl_map(function(lsp) return lsp.name end, clients)
    return table.concat(names, ", ")
end

local function update_diffs()
    if not vim.b[0].gitsigns_status_dict then
        return ""
    end
    local status = vim.b[0].gitsigns_status_dict

    local res = {}
    if status.added and status.added > 0 then
        table.insert(res, string.format("%%#StatusDiffAdded#+%d ", status.added))
    end
    if status.changed and status.changed > 0 then
        table.insert(res, string.format("%%#StatusDiffChanged#~%d ", status.changed))
    end
    if status.removed and status.removed > 0 then
        table.insert(res, string.format("%%#StatusDiffRemoved#-%d ", status.removed))
    end

    return table.concat(res)
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
    local bg = theme.blend(theme.colors.green, theme.colors.teal, (i / 10))
    local fg = theme.palettes.default.inverted
    vim.api.nvim_set_hl(0, "StatusProgress" .. i, {
        bg = bg,
        fg = fg,
    })
    vim.api.nvim_set_hl(0, "StatusLInvProgress" .. i, {
        fg = bg,
        bg = theme.palettes.default.bg2,
    })
    vim.api.nvim_set_hl(0, "StatusRInvProgress" .. i, {
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

    local hl = "Progress" .. as_int
    return " " .. left_sep(hl) .. string.format("%%#Status%s#%s", hl, text) .. right_sep(hl)
end

local sections
local redraw = function()
    vim.o.statusline = table.concat(sections)
end

local indices = {
    mode = 1,
    title = 3,
    lsp = 5,
    diagnostics = 6,
    macro = 9,
    diffs = 12,
    filetype = 14,
    wordcount = 15,
    progress = 16,
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

api.nvim_create_autocmd({ "LspAttach", "LspDetach", "BufEnter", "BufLeave" }, {
    group = augroup,
    callback = function()
        sections[indices.lsp] = update_lsp_names()
        redraw()
    end
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
    update_mode(),      -- mode
    " %#StatusSection1#",
    update_title(),     -- title of buf with modified etc
    " " .. right_sep("Section1") .. "%#StatusSection2# ",
    "",                 -- lsp name
    "",                 -- lsp warnings erorrs etc
    right_sep("Section2"),
    "%#StatusCenter# ", --
    "",                 -- macro
    " %S%= %l:%c ",     -- keys, right align and position
    left_sep("Section2") .. "%#StatusSection2# ",
    "",                 -- diff
    left_sep("Section1") .. "%#StatusSection1# ",
    "",                 -- filetype
    "",                 -- wordcount
    update_progress(),  -- % in file
}

vim.o.laststatus = 3
vim.o.showcmdloc = "statusline"

redraw()


return M
