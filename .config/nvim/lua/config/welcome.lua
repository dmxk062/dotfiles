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

---@type config.welcome.state
local State = {
    draw_row = 0,
    first_row = 2,
    constrain = {},
    actions = {},
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
        "Git Status",
        desc = "Fugitive :G",
        key = "S",
        on_click = vim.cmd.Git,
        hl = "WelcomeGitStatus"
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
    local left_pad = get_center_padding(BUTTON_WIDTH)
    table.insert(State.constrain, {
        start = State.draw_row,
        stop = State.draw_row + #Actions,
        col = left_pad + 1,
    })

    local pad_spaces = (" "):rep(left_pad)
    for i, act in ipairs(Action_lines) do
        act[1] = { pad_spaces }
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
        local timestring = os.date("%b/%y %d, %H:%M ", mtime)
        local timehl = utils.highlight_time(mtime)

        local tail = fn.fnamemodify(file, ":t")
        local head = utils.expand_home(fn.fnamemodify(file, ":h"), 4)
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

    local initial_pad = get_center_padding(BUTTON_WIDTH)
    local start_spaces = (" "):rep(initial_pad)
    insert_heading("[r] Recent Files", "WelcomeRecents", Recents_show_all)

    local how_many = Recents_show_all
        and #Oldfiles
        or math.min(State.drawable, #Oldfiles, 10)

    table.insert(State.constrain, {
        start = State.draw_row,
        stop = State.draw_row + how_many,
        col = initial_pad + 1,
    })

    local lines = {}
    for i = 1, how_many do
        local file = Oldfiles[i]

        local prefix = { start_spaces }
        if i <= 10 then
            prefix = { start_spaces .. ("[%d] "):format(i - 1), "Number" }
        end
        local center_pad = (" "):rep(MAX_FILE_NAME - file.namewidth - (i <= 10 and 4 or 0))

        file.text[1] = prefix
        file.text[3] = { center_pad }
        State.actions[State.draw_row + i] = function()
            vim.cmd.edit(file.path)
        end
        table.insert(lines, file.text)
    end
    insert_text(lines)
end

-- }}}

local update_size = function()
    State.width = api.nvim_win_get_width(State.win)
    State.height = api.nvim_win_get_height(State.win)
end

local do_redraw = function()
    State.constrain = {}
    State.actions = {}
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
    Recents()

    vim.bo[buf].modifiable = false
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
    do_redraw()

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
    end)

    for _, action in ipairs(Actions) do
        map("n", action.key, action.on_click)
    end

    map("n", "r", function()
        Recents_show_all = not Recents_show_all
        do_redraw()
    end)

    for i = 0, 9 do
        map("n", tostring(i), function()
            local file = Oldfiles[i+1].path
            if file then
                vim.cmd.edit(file)
            end
        end)
    end
end

return M
