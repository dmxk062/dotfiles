local M = {}
local api = vim.api
local fn = vim.fn
local utils = require("config.utils")
local format_buf_name = utils.format_buf_name
local btypehighlights, btypesymbols = utils.btypehighlights, utils.btypesymbols

-- my own statusline
-- this should be faster than lualine
-- generally, only redraw things using autocmds unless there isnt a good one for the event

local function esc(str)
    return str:gsub("%%", "%%%%")
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
    t      = "Insert",
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
    name = name and esc(name)

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
        table.insert(res, string.format("%%#SlError#!%d", err))
    end
    if warn > 0 then
        table.insert(res, string.format("%%#SlWarning#!%d", warn))
    end
    if hint > 0 then
        table.insert(res, string.format("%%#SlHint#?%d", hint))
    end
    if info > 0 then
        table.insert(res, string.format("%%#SlInfo#.%d", info))
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

local function get_fugitive_info()
    local res = {}
    local head = fn.FugitiveHead(8)
    if head and head ~= "" then
        table.insert(res, string.format("%%#SlGitHead#󰘬 %s", head))
    end

    ---@type string
    local object = fn["fugitive#Object"](api.nvim_buf_get_name(0))
    if object then
        if vim.startswith(object, "/tmp") then
            object = "log"
        elseif object:match("^%x+$") then
            object = object:sub(0, 7)
        elseif object:match("^%x+:.*$") then
            object = "@" .. object:sub(0, 7)
        elseif object == ":" then
            object = "status"
        else
            local ago = object:match("^:(%d+):.*")
            if ago == "0" then
                object = "HEAD"
            end
        end
        table.insert(res, string.format("%%#SlGitHash#%s", object))
    end

    return " %#SlASL#" .. table.concat(res, " ") .. "%#SlASR#"
end

local function update_git()
    if vim.b[0].fugitive_type then
        return get_fugitive_info()
    end

    if not vim.b[0].gitsigns_status_dict then
        return ""
    end
    local status = vim.b[0].gitsigns_status_dict

    local res = {}
    if status.head then
        table.insert(res, string.format("%%#SlGitHead#󰘬 %s", status.head))
    end

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
    local ft = vim.bo.filetype

    return ft and ft ~= "" and ft or "[noft]"
end

local function update_lsp_servers()
    local clients = vim.lsp.get_clients { bufnr = 0 }

    ---@param c vim.lsp.Client
    local display = vim.tbl_map(function(c)
        return "%#SlHint#*" .. c.name
    end, clients)

    return " " .. table.concat(display, ", ")
end

local sections
local redraw = function()
    vim.o.statusline = table.concat(sections)
end

local indices = {
    mode = 1,
    title = 2,
    git = 3,
    diagnostics = 4,
    macro = 5,
    lsp_messages = 7,
    filetype = 9,
    lsp = 10,
}

-- Autocommands {{{
utils.autogroup("config.statusline", {
    ModeChanged = function(ev)
        -- stop flickering
        if vim.bo[ev.buf].filetype == "TelescopePrompt" then
            return
        end
        sections[indices.mode] = update_mode()
        redraw()
    end,
    [{ "BufEnter", "BufLeave", "WinEnter", "BufModifiedSet", "FileChangedRO", "TermRequest" }] =
        vim.schedule_wrap(function()
            sections[indices.title] = update_title()
            sections[indices.git] = update_git()
            sections[indices.lsp] = update_lsp_servers()
            redraw()
        end),

    [{ "BufEnter", "FileType", "BufLeave" }] =
        vim.schedule_wrap(function()
            -- prevent completion etc
            if api.nvim_get_mode().mode:sub(1, 1) ~= "n" then
                return
            end
            sections[indices.filetype] = update_filetype()
            redraw()
        end),

    [{ "RecordingEnter", "RecordingLeave" }] =
        function(ev)
            sections[indices.macro] = update_macro(ev.event)
            redraw()
        end,

    [{ "LspAttach", "LspDetach" }] =
        vim.schedule_wrap(function()
            sections[indices.lsp] = update_lsp_servers()
            redraw()
        end),

    LspProgress = function(ev)
        local data = ev.data
        local client = vim.lsp.get_client_by_id(data.client_id)
        if not client then
            return
        end

        local value = data.params.value

        if value.kind == "end" then
            sections[indices.lsp_messages] = ""
        else
            sections[indices.lsp_messages] = string.format(
                "%%#Identifier#*%s%%#Delimiter#: %%#Normal#%s %%#Number#%02d%%%%",
                client.name,
                esc(value.title),
                value.percentage
            )
        end
        redraw()
    end,

    User = {
        pattern = { "FugitiveChanged", "FugitiveObject", "GitSignsUpdate" },
        callback = vim.schedule_wrap(function()
            sections[indices.git] = update_git()
        end)
    },
})
-- }}}

-- only updates in normal mode
local normal_timer = vim.uv.new_timer()
normal_timer:start(0, 100, vim.schedule_wrap(function()
    if api.nvim_get_mode().mode:sub(1, 1) ~= "n" then
        return
    end
    sections[indices.diagnostics] = update_diagnostics()
    redraw()
end)
)

-- prefill the line
-- some will be static, some only updated via autocmd, some via timer
sections = {
    update_mode(),                                                -- mode
    update_title(),                                               -- title of buf with modified etc
    "",                                                           -- git
    "",                                                           -- diagnostics
    "",                                                           -- macro
    " %#SlRow#%3l%#Delimiter#:%#SlCol#%-3c %#SlKeys#%-3(%S%)%= ", -- keys, position and right align
    "",                                                           -- lsp messages
    " %#SlASL#%#SlAText#",
    "",                                                           -- filetype
    "",                                                           -- attached lsps
    "%#SlASR# ",
}

vim.o.laststatus = 3
vim.o.showcmdloc = "statusline"

redraw()


return M
