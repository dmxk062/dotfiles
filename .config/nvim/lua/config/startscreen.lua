local M = {}
local utils = require("config.utils")
local api = vim.api
local fn = vim.fn

--[[ Just eye-candy on startup {{{
Shows common actions and a few sentences on start
}}} ]]

-- Helpers {{{
local state = {
    buf = 0,
    win = 0,
    cur_row = 0,
    cur_col = 0,
    ns = 0,
    augroup = 0,
    first_editable = 0,
    last_editable = 0,
    was_newline = false,
    set_col = 0,
}

---Print a line with a highlight group
---@param string string text to print
---@param hlgroup string highlight group of text
---@param offset integer padding from the left
---@param do_newline boolean display a newline afterwards
local function print_hl_line(string, hlgroup, offset, do_newline)
    if do_newline == nil then
        do_newline = true
    end
    local padded = (" "):rep(offset) .. string
    local width = #padded
    if state.was_newline then
        api.nvim_buf_set_lines(state.buf, state.cur_row, state.cur_row, false, { padded })
    else
        api.nvim_buf_set_text(state.buf, state.cur_row, state.cur_col, state.cur_row, state.cur_col, { padded })
    end
    api.nvim_buf_add_highlight(state.buf, state.ns, hlgroup, state.cur_row, state.cur_col, state.cur_col + width)

    if do_newline then
        state.cur_col = 0
        state.cur_row = state.cur_row + 1
        state.was_newline = true
    else
        state.cur_col = state.cur_col + width
        state.was_newline = false
    end
end

---print count lines of padding
---@param count integer
local function print_padding_lines(count)
    local tbl = {}
    for i = 1, count do
        tbl[i] = ""
    end
    api.nvim_buf_set_lines(state.buf, state.cur_row, state.cur_row + count, false, tbl)


    state.cur_col = 0
    state.cur_row = state.cur_row + count
    state.was_newline = true
end
-- }}}

-- Banner {{{
local Letters = {
    ---@format disable
    {
        [[                      ]],
        [[       ████ ██████]],
        [[      ███████████]],
        [[      █████████]],
        [[     █████████]],
        [[    █████████]],
        [[  ███████████]],
        [[ ██████  ███]],
    },
    {
        [[          ]],
        [[          ]],
        [[         ]],
         [[ ████████]],
        [[  ███    ]],
       [[ ████████]],
       [[ ███    ]],
      [[█████████]],
    },
    {
        [[]],
        [[]],
        [[   ]],
           [[███]],
          [[█████]],
         [[██ ██]],
        [[███ ███]],
        [[█████████]],
    },
    {
        [[              ]],
        [[ █████      ]],
         [[ █████    ]],
           [[████████ ]],
            [[████████ ]],
             [[███████ ]],
              [[██████ ]],
              [[ ████ ]],
    },
    {
        [[   ]],
        [[██ ]],
        [[      ]],
        [[███ ]],
        [[█████]],
        [[█████]],
        [[█████]],
        [[█████]],
    },
    {
        [[                 ]],
        [[                 ]],
        [[                 ]],
        [[  ███████████]],
        [[ ██████████████]],
        [[ █████ ████ █████]],
        [[ █████ ████ █████]],
        [[ █████ ████ ██████]],
    }
    ---@format enable
}
-- }}}

-- Actions {{{
local Buttons = {
    {
        map = "s",
        cb = function()
            require("config.terminal").open_term { position = "autosplit" }
        end,
        text = "Shell Buffer",
        hl = "Shell",
        icon = ""
    },
    {
        map = "n",
        cb = function()
            vim.cmd.enew()
        end,
        text = "New Buffer",
        hl = "New",
        icon = "󰈔",
    },
    {
        map = "o",
        cb = function() require("telescope.builtin").oldfiles() end,
        text = "Search Oldfiles",
        hl = "History",
        icon = "󰋚",
    },
    {
        map = "F",
        cb = function() require("telescope.builtin").find_files() end,
        text = "Search Files",
        hl = "Search",
        icon = "󰺄",
    },
    {
        map = "f",
        cb = function() require("oil").open() end,
        text = "Edit Directory",
        hl = "Files",
        icon = "󰉋",
    },
    {
        map = "G",
        cb = function()
            vim.cmd("Git")
        end,
        text = "Git Status",
        hl = "Git",
        icon = "󰊢",
    },
    {
        map = "L",
        cb = vim.cmd.Lazy,
        text = "Lazy.nvim - Plugins",
        hl = "Lazy",
        icon = "",
    },
    {
        map = "M",
        cb = vim.cmd.Mason,
        text = "Mason - Packages",
        hl = "Mason",
        icon = "",
    },
    {
        map = "q",
        cb = vim.cmd.q,
        text = "Exit Neovim",
        hl = "Quit",
        icon = "󰿅",
    },
}
-- }}}

local function draw_logo(size)
    if size.rows < (#Letters[1] + #Buttons + 4) then
        return
    end
    local start_row = math.floor((size.rows - #Letters[1] - #Buttons - 2) / 2)
    print_padding_lines(start_row - 1)
    local text_len = 0
    for _, ltr in pairs(Letters) do
        text_len = text_len + fn.strdisplaywidth(ltr[1])
    end
    local start_offset = math.floor((size.cols - text_len) / 2)

    if text_len < size.cols - 4 then
        for i = 1, #Letters[1] do
            for j = 1, #Letters do
                print_hl_line(Letters[j][i], "StartscreenTitle" .. j, j == 1 and start_offset or 0, j == #Letters)
            end
        end
    end
end

local line_handlers = {}
local target_widths = {
    lim = 46,
    lower = 24,
    higher = 40
}

---@param opts {text: string, hl: string, cb: function, map: string, icon: string}
local function button(size, opts)
    state.set_col = size.padd + 3

    line_handlers[state.cur_row + 1] = opts.cb
    local text = opts.icon .. " " .. opts.text
    local text_len = #opts.text + 2 -- assume icon always has length 1
    print_hl_line(text, "Startscreen" .. opts.hl, size.padd, false)

    local mapping = "<" .. opts.map .. ">"
    local missing_padd = (size.target - (text_len))

    print_hl_line(mapping, "Startscreen" .. opts.hl, missing_padd, true)

    vim.keymap.set("n", opts.map, opts.cb, { buffer = state.buf })
end

---@param opts {text: string, hl: string}
local function centered_text(size, opts)
    local width = fn.strdisplaywidth(opts.text)
    local padd = math.floor((size.cols - width) / 2)
    print_hl_line(opts.text, "Startscreen" .. opts.hl, padd, false)
end

local function draw_screen()
    vim.bo[state.buf].modifiable = true
    api.nvim_buf_set_lines(state.buf, 0, -1, false, {})
    state.cur_row = 0
    state.cur_col = 0
    state.first_editable = 0
    state.was_newline = false
    line_handlers = {}

    local cols = api.nvim_win_get_width(state.win)
    local rows = api.nvim_win_get_height(state.win)
    local target = cols > target_widths.lim and target_widths.higher or target_widths.lower
    local padd = math.floor((cols - target) / 2)

    local size = {
        cols = cols,
        rows = rows,
        target = target,
        padd = padd
    }

    draw_logo(size)
    print_padding_lines(3)
    state.first_editable = state.cur_row + 1

    vim.tbl_map(function(btn) button(size, btn) end, Buttons)

    state.last_editable = state.cur_row
    if rows > state.cur_row + 2 then
        print_padding_lines(rows - state.cur_row - 2)
        centered_text(size, { text = M.texts[(fn.rand() % #M.texts) + 1], hl = "Text" })
    end
    vim.bo[state.buf].modifiable = false
    vim.bo[state.buf].modified = false
end

local saved_opts = {
    number = false,
    relativenumber = false,
    foldenable = false,
    statuscolumn = "",
}

function M.show_start_screen()
    state.buf = api.nvim_get_current_buf()
    state.win = api.nvim_get_current_win()
    state.ns = api.nvim_create_namespace("Startscreen")
    state.augroup = api.nvim_create_augroup("Startscreen", {})

    for k, v in pairs(saved_opts) do
        vim.wo[state.win][0][k] = v
    end

    vim.bo[0].buftype = "nofile"
    vim.bo[0].buflisted = false

    -- constrain cursor
    api.nvim_create_autocmd("CursorMoved", {
        buffer = state.buf,
        group = state.augroup,
        callback = function(ctx)
            local pos = api.nvim_win_get_cursor(0)
            local row
            if pos[1] <= state.first_editable then
                row = state.first_editable
            elseif pos[1] >= state.last_editable then
                row = state.last_editable
            else
                row = pos[1]
            end
            fn.setcursorcharpos(row, state.set_col)
        end
    })

    api.nvim_create_autocmd({ "WinResized" }, {
        group = state.augroup,
        callback = draw_screen,
    })

    api.nvim_create_autocmd({ "BufWinLeave", "BufHidden" }, {
        buffer = state.buf,
        once = true,
        group = state.augroup,
        callback = function(ctx)
            api.nvim_del_augroup_by_id(state.augroup)
            vim.defer_fn(function()
                api.nvim_buf_delete(state.buf, { force = true })
            end, 10)
        end
    })

    vim.keymap.set("n", "<CR>", function()
        local row = api.nvim_win_get_cursor(0)[1]
        if line_handlers[row] then
            line_handlers[row]()
        end
    end, { buffer = state.buf })

    draw_screen()
end

M.texts = {
    "Never :q me for emacs",
    "Prefer using :h text-objects over motions",
    "Enjoy your day!",
    ":3 is a valid ex command, and you're valid too",
    "Tired? Just <C-z>",
    ":v == :g!",
    ":find is often faster than :e",
    "All your issues are in the :cwindow",
    "g:<textobj>",
    "Þæs ofereode, þisses swā mæġ",
    "Gæð a wyrd swā heo sċeal"
}

return M
