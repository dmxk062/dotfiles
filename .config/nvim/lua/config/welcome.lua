local api = vim.api
local fn = vim.fn
local utils = require("config.utils")
local ns = api.nvim_create_namespace("config.welcome")

local M = {}

---@class config.welcome.state
---@field buf integer?
---@field win integer?
---@field autogroup integer?
---@field width integer?
---@field height integer?
---@field drawable integer?
---@field draw_row integer
---@field first_row integer
---@field constrain ({start: integer, stop: integer, col: integer})[]
---@field actions function[]
---@field files string[]
---@field left_pad integer?
---@field start_spaces string?

---@type config.welcome.state
local State = {
    draw_row = 0,
    first_row = 2,
    constrain = {},
    actions = {},
    files = {}
}

-- Helpers {{{
local map = function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = State.buf

    vim.keymap.set(mode, lhs, rhs, opts)
end
local strwidth = require("plenary.strings").strdisplaywidth
local linewidth = function(line)
    local width = 0
    for _, chunk in pairs(line) do
        width = width + strwidth(chunk[1])
    end

    return width
end

---@param params vim.api.keyset.create_autocmd
local autocmd = function(event, params)
    params.group = State.autogroup
    api.nvim_create_autocmd(event, params)
end

local take_lines = function(count)
    State.drawable = State.drawable - count
end

local advance_lines = function(count)
    State.draw_row = State.draw_row + count
    take_lines(count)
end

local insert_empty = function(count)
    local lines = {}
    for _ = 1, count do
        table.insert(lines, "")
    end

    api.nvim_buf_set_lines(State.buf, State.draw_row, State.draw_row, false, lines)
    advance_lines(count)
end

---@param row integer
---@param col integer
---@param mark vim.api.keyset.set_extmark
local set_extmark = function(row, col, mark)
    api.nvim_buf_set_extmark(State.buf, ns, row, col, mark)
end

local insert_text = function(lines)
    local text = vim.tbl_map(function(line)
        return table.concat(vim.tbl_map(function(chunk)
            return chunk[1]
        end, line))
    end, lines)

    api.nvim_buf_set_lines(State.buf, State.draw_row, State.draw_row + #lines, false, text)

    for i, line in ipairs(lines) do
        local acc = 0
        for _, chunk in ipairs(line) do
            local endcol = acc + #chunk[1]
            set_extmark(State.draw_row + i - 1, acc, {
                hl_group = chunk[2],
                end_col = endcol,
            })
            acc = endcol
        end
    end

    advance_lines(#lines)
end

local set_virt_lines = function(row, lines, before)
    set_extmark(row, 0, {
        virt_lines_above = before,
        virt_lines = lines
    })
    take_lines(#lines)
end

local insert_heading = function(title, hl, expanded)
    local text = string.format("%s %s ", title, expanded and "" or "")
    local width = strwidth(text)
    local remaining_width = State.width - width
    local half_width = math.floor(remaining_width / 2)

    local left_pad = ("-"):rep(half_width)
    local right_pad
    if remaining_width % 2 == 0 then
        right_pad = left_pad
    else
        right_pad = ("-"):rep(half_width + 1)
    end



    set_virt_lines(State.draw_row - 1, {
        { { "" } },
        { { left_pad, "WinSeparator" }, { text, hl }, { right_pad, "WinSeparator" } },
    })
end


local get_center_padding = function(width)
    return math.floor((State.width - width) / 2)
end

local get_center_spaces = function(width)
    return (" "):rep(get_center_padding(width))
end

local EMPTY_LINE = { { "" } }
-- }}}

-- Data {{{
local Letters = vim.tbl_map(function(row)
    local elements = { "" } -- leave one element to cheaply insert padding
    for i = 1, #row do
        table.insert(elements, { row[i], "WelcomeTitle" .. i })
    end
    return elements
end, {
    ---@format disable
    {"      ████ ██████","          ",""," █████      ","██ ","                 "},
    {"     ███████████","         ","   "," █████    ","      ","                "},
    {"     █████████"," ████████","███","████████ ","███ ","  ███████████"},
    {"    █████████","  ███    ","█████","████████ ","█████"," ██████████████"},
    {"   █████████"," ████████","██ ██","███████ ","█████"," █████ ████ █████"},
    {" ███████████"," ███    ","███ ███","██████ ","█████"," █████ ████ █████"},
    {"██████  ███","█████████","█████████"," ████ ","█████"," █████ ████ ██████"},
    ---@format enable
})
local LETTER_WIDTH = 70

local Messages = {
    ":3 is a valid ex command, and you're valid too 🏳️‍⚧️",
    ":find is often faster than :e",
    "All your issues are in the :cwindow",
    "Enjoy your day!",
    "Gæð a wyrd swā heo sċeal",
    "It is our duty to keep computing gay, we owe that to Turing",
    "Never :q me for emacs",
    "Prefer using :h text-objects over motions",
    "Tired? Just <C-z>",
    "Þæs ofereode, þisses swā mæġ",
}
local get_random_message = function()
    return Messages[(vim.fn.rand() % #Messages) + 1]
end

-- }}}

-- Title and Message {{{
local Title = function()
    if State.drawable < #Letters or State.width < LETTER_WIDTH then
        return
    end

    local spaces = get_center_spaces(LETTER_WIDTH)
    for _, ltr in pairs(Letters) do
        ltr[1] = { spaces }
    end

    set_virt_lines(State.draw_row, Letters)
end

local Lazy_message
local update_lazy = function()
    local Lazy_stats = require("lazy").stats()

    local lazy_time = Lazy_stats.times.LazyDone - Lazy_stats.times.LazyStart
    Lazy_message = { nil, { "Lazy:",    "WelcomeProperty" }, { " loaded " },
        { ("%d"):format(Lazy_stats.loaded), "Number" },
        { " of " }, { ("%d"):format(Lazy_stats.count), "Number" },
        { " plugins in " }, { ("%.2fms"):format(lazy_time), "WelcomeTime" },
        { ", " }, { ("%.2fms"):format(Lazy_stats.times.UIEnter or 0), "WelcomeTime" }, { " in total" },
    }
end
update_lazy()

local Current_message = get_random_message()
local Message = function()
    local width = strwidth(Current_message)
    Lazy_message[1] = nil
    Lazy_message[1] = { get_center_spaces(linewidth(Lazy_message)) }

    set_virt_lines(State.draw_row, {
        EMPTY_LINE,
        Lazy_message,
        EMPTY_LINE,
        { { get_center_spaces(width) }, { Current_message, "WelcomeMessage" } },
    })
end
-- }}}

-- Shortcuts {{{
local Actions = {
    {
        "Shell",
        desc = "New Terminal",
        key = "!",
        on_click = function()
            require("config.terminal").open_term { position = "autosplit" }
        end,
        hl = "WelcomeNewShell"
    },
    {
        "Open Buffer",
        desc = "Empty Buffer",
        key = "o",
        on_click = vim.cmd.new,
        hl = "WelcomeNewBuffer"
    },
    {
        "Find Files",
        desc = "Using 'fd'",
        key = "F",
        on_click = function()
            require("telescope.builtin").find_files()
        end,
        hl = "WelcomeFindFiles"
    },
    {
        "Lua Eval",
        desc = "Lua Scratch Buffer",
        key = "E",
        on_click = function()
            require("config.scratch").show_scratch_buffer {
                name = "eval",
                type = "lua",
                win = {}
            }
        end,
        hl = "WelcomeLuaScratch"
    },
    {
        "Edit Filesystem",
        desc = "Oil Buffer",
        key = "f",
        on_click = function()
            require("oil").open()
        end,
        hl = "WelcomeEditFiles"
    },
    {
        "Plugins",
        desc = "Lazy",
        key = "L",
        on_click = vim.cmd.Lazy,
        hl = "WelcomeLazy"
    },
    {
        "Packages",
        desc = "Mason",
        key = "M",
        on_click = vim.cmd.Mason,
        hl = "WelcomeMason"
    },
    {
        "Quit NeoVIM",
        desc = "Goodbye :3",
        key = "q",
        on_click = vim.cmd.quit,
        hl = "WelcomeQuit"
    }
}
local BUTTON_WIDTH = 60
local Action_lines = vim.tbl_map(function(action)
    local textwidth = strwidth(action[1])
    local descwidth = strwidth(action.desc)
    local missing_pad = BUTTON_WIDTH - (textwidth + descwidth + 5)
    local text = ("[%s] %s%s%s"):format(action.key, action[1], (" "):rep(missing_pad), action.desc)

    return { nil, { text, action.hl } }
end, Actions)

local Buttons = function()
    table.insert(State.constrain, {
        start = State.draw_row,
        stop = State.draw_row + #Actions,
        col = State.left_pad + 1,
    })

    for i, act in ipairs(Action_lines) do
        act[1] = { State.start_spaces }
        State.actions[State.draw_row + i] = Actions[i].on_click
    end
    insert_text(Action_lines)
end
-- }}}

-- Oldfiles List {{{
local Oldfiles = {}
local MAX_FILE_NAME = 0
for _, file in ipairs(vim.v.oldfiles) do
    local is_oil = vim.startswith(file, "oil://")
    local highlight
    if is_oil then
        file = file:sub(7, -2)
        highlight = "Directory"
    end
    local st = vim.uv.fs_stat(file)
    if st then
        if not highlight then
            highlight = utils.highlight_fname(file)
        end

        local mtime = st.mtime.sec
        local timestring = os.date("%b/%y %d, %H:%M  ", mtime)
        local timehl = utils.highlight_time(mtime)

        local tail = fn.fnamemodify(file, ":t")
        local head = utils.expand_home(fn.fnamemodify(file, ":h"), 6)
        local text = { nil, { tail, highlight }, nil, { timestring, timehl }, { head, "NonText" } }

        local namewidth = strwidth(tail)
        if namewidth > MAX_FILE_NAME then
            MAX_FILE_NAME = namewidth
        end

        table.insert(Oldfiles, {
            path = file,
            text = text,
            namewidth = namewidth
        })
    end
end

local Recents_show_all = false
local Recents = function()
    if State.drawable < 4 then
        return
    end

    insert_heading("[r] Recent Files", "WelcomeRecents", Recents_show_all)

    local how_many = Recents_show_all
        and #Oldfiles
        or math.min(State.drawable, #Oldfiles, 10)

    table.insert(State.constrain, {
        start = State.draw_row,
        stop = State.draw_row + how_many,
        col = State.left_pad + 1,
    })

    local lines = {}
    for i = 1, how_many do
        local file = Oldfiles[i]

        local prefix = { State.start_spaces }
        if i <= 10 then
            prefix = { State.start_spaces .. ("[%d] "):format(i - 1), "Number" }
        end
        local center_pad = (" "):rep(MAX_FILE_NAME - file.namewidth - (i <= 10 and 4 or 0))

        file.text[1] = prefix
        file.text[3] = { center_pad }
        State.files[State.draw_row + i] = file.path
        table.insert(lines, file.text)
    end

    insert_text(lines)
end

-- }}}

-- Git Section {{{
local git_highlights = {
    M = "Changed",
    D = "Deleted",
    A = "Added",
    ["."] = "NonText",
    R = "Label"
}
local MAX_GIT_NAME = BUTTON_WIDTH - 20
---@param entry config.git.item
local git_format_line = function(entry)
    local file = entry.path
    local filehl = utils.highlight_fname(file)
    local tail = fn.fnamemodify(file, ":t")
    local head = fn.fnamemodify(file, ":h")

    local namewidth = strwidth(tail) + 10
    if namewidth > MAX_GIT_NAME then
        MAX_GIT_NAME = namewidth
    end

    local line = { nil, -- leave padding
        { entry.skind, git_highlights[entry.skind] },
        { entry.kind,  git_highlights[entry.kind] },
        { " " },
        { tail,        filehl },
        nil,
        { " " .. head, "NonText" },
    }

    return { text = line, width = namewidth, entry = entry }
end


---@type config.git.info?
local Git_info
local Git_staged_lines
local Git_unstaged_lines
local Git_ignored_lines
local update_git = function(cb)
    utils.git_get_status({ cwd = vim.fn.getcwd() }, function(res)
        Git_staged_lines = {}
        Git_unstaged_lines = {}
        for _, e in pairs(res.modified) do
            table.insert(e.staged and Git_staged_lines or Git_unstaged_lines, git_format_line(e))
        end

        Git_info = res
        if cb then
            vim.schedule(cb)
        end
    end)
end

local git_insert_entries = function(entries)
    local lines = {}
    for i, entry in ipairs(entries) do
        local center_pad = (" "):rep(MAX_GIT_NAME - entry.width)
        entry.text[1] = { State.start_spaces }
        entry.text[6] = { center_pad }
        table.insert(lines, entry.text)
        State.files[State.draw_row + i] = entry.entry.path
    end
    insert_text(lines)
end

Git_expanded = false
local Git_section = function()
    if not Git_info then
        return
    end
    insert_heading("[S] Git Status", "WelcomeGit", Git_expanded)

    local how_many = (Git_expanded and #Git_unstaged_lines or 0) + #Git_staged_lines + 4
    table.insert(State.constrain, {
        start = State.draw_row,
        stop = State.draw_row + how_many,
        col = State.left_pad,
    })

    insert_text {
        { { State.start_spaces }, { "Branch: ", "WelcomeProperty" }, { Git_info.head, "Identifier" },
            { " +" .. Git_info.ahead, "Added" }, { " -" .. Git_info.behind, "Deleted" },
            { " -> ", "NonText" }, { Git_info.upstream, "Identifier" } },
        {
            { State.start_spaces },
            { "Untracked: ",     "fugitiveUntrackedHeading" }, { tostring(#Git_info.untracked), "Number" },
            { ", " }, { "Unstaged: ", "fugitiveUnstagedHeading" }, { tostring(#Git_unstaged_lines), "Number" },
            { ", " }, { "Staged: ", "fugitiveStagedHeading" }, { tostring(#Git_staged_lines), "Number" }
        },
    }
    State.actions[State.draw_row] = function()
        vim.cmd.Git()
    end
    set_virt_lines(State.draw_row - 1, { { { "" } } })

    git_insert_entries(Git_staged_lines)

    if not Git_expanded then
        return
    end

    git_insert_entries(Git_unstaged_lines)
end
-- }}}

local update_size = function()
    State.width = api.nvim_win_get_width(State.win)
    State.height = api.nvim_win_get_height(State.win)
    State.left_pad = get_center_padding(BUTTON_WIDTH)
    State.start_spaces = (" "):rep(State.left_pad)
end

local Cursor
local save_cursor = function()
    Cursor = api.nvim_win_get_cursor(State.win)
end
local restore_cursor = function()
    api.nvim_win_set_cursor(State.win, Cursor)
end

local do_redraw = function()
    save_cursor()
    State.constrain = {}
    State.actions = {}
    State.files = {}
    State.draw_row = 0
    State.drawable = State.height
    local buf = State.buf or 0
    vim.bo[buf].modifiable = true
    api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    api.nvim_buf_set_lines(buf, 0, -1, false, {})

    Title()
    Message()
    advance_lines(1)
    insert_empty(1)

    State.first_row = State.draw_row + 1
    Buttons()
    Git_section()
    Recents()

    vim.bo[buf].modifiable = false
    restore_cursor()
end

M.show = function()
    local buf = api.nvim_create_buf(false, true); State.buf = buf
    local win = api.nvim_get_current_win(); State.win = win

    api.nvim_win_set_buf(win, buf)

    State.autogroup = api.nvim_create_augroup("config.welcome", { clear = true })
    vim.bo[buf].buftype = "nofile"

    local wo = vim.wo[0][0]
    wo.number = false
    wo.relativenumber = false
    wo.foldenable = false
    wo.statuscolumn = ""

    update_size()
    update_git(do_redraw)
    do_redraw()

    -- Set handlers for events {{{
    autocmd("WinResized", {
        buffer = buf,
        callback = function()
            update_size()
            do_redraw()
        end
    })

    autocmd("User", {
        pattern = "LazyLoad",
        callback = function()
            update_lazy()
            do_redraw()
        end
    })

    autocmd({ "BufWinLeave", "BufHidden" }, {
        buffer = buf,
        once = true,
        callback = function()
            api.nvim_del_augroup_by_id(State.autogroup)
            vim.defer_fn(function()
                api.nvim_buf_delete(buf, { force = true })
            end, 10)
        end
    })

    autocmd("CursorMoved", {
        buffer = buf,
        callback = function()
            local pos = api.nvim_win_get_cursor(State.win)
            local row = pos[1]

            if row < State.first_row then
                row = State.first_row
            end

            for _, region in ipairs(State.constrain) do
                if row >= region.start and row <= region.stop then
                    if pos[2] ~= region.col then
                        pcall(api.nvim_win_set_cursor, State.win, { row, region.col })
                    end
                    return
                end
            end
        end
    })

    map("n", "<cr>", function()
        local line = api.nvim_win_get_cursor(State.win)[1]
        local action = State.actions[line]
        if action then
            action()
        end

        local file = State.files[line]
        if file then
            vim.cmd.edit(file)
        end
    end)

    for _, action in ipairs(Actions) do
        map("n", action.key, action.on_click)
    end

    map("n", "r", function()
        Recents_show_all = not Recents_show_all
        do_redraw()
    end)
    map("n", "S", function()
        Git_expanded = not Git_expanded
        do_redraw()
    end)

    for i = 0, 9 do
        map("n", tostring(i), function()
            local file = Oldfiles[i + 1].path
            if file then
                vim.cmd.edit(file)
            end
        end)
    end

    -- }}}
end

return M
