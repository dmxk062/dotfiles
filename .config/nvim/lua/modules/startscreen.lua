local M = {}

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

local function print_hl_line(string, hlgroup, offset, do_newline)
    if do_newline == nil then
        do_newline = true
    end
    local padded = (" "):rep(offset) .. string
    local width = #padded
    if state.was_newline then
        vim.api.nvim_buf_set_lines(state.buf, state.cur_row, state.cur_row, false, { padded })
    else
        vim.api.nvim_buf_set_text(state.buf, state.cur_row, state.cur_col, state.cur_row, state.cur_col, { padded })
    end
    vim.api.nvim_buf_add_highlight(state.buf, state.ns, hlgroup, state.cur_row, state.cur_col, state.cur_col + width)

    if do_newline then
        state.cur_col = 0
        state.cur_row = state.cur_row + 1
        state.was_newline = true
    else
        state.cur_col = state.cur_col + width
        state.was_newline = false
    end
end

local function print_padding_lines(count)
    local tbl = {}
    for i = 1, count do
        tbl[i] = ""
    end
    vim.api.nvim_buf_set_lines(state.buf, state.cur_row, state.cur_row + count, false, tbl)


    state.cur_col = 0
    state.cur_row = state.cur_row + count
    state.was_newline = true
end



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

local Buttons = {
    {
        map = "n",
        cb = function()
            vim.cmd.new()
            vim.cmd.only()
        end,
        text = "New Buffer",
        hl = "New",
        icon = "󰈔",
    },
    {
        map = "h",
        cb = function() require("telescope.builtin").oldfiles {} end,
        text = "Search History",
        hl = "History",
        icon = "󰋚",
    },
    {
        map = "/",
        cb = function() require("telescope.builtin").find_files {} end,
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
        map = "J",
        cb = function() vim.cmd("Neorg journal today") end,
        text = "Journal",
        hl = "Journal",
        icon = "󰂺",
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

local function draw_logo(size)
    if size.rows < (#Letters[1] + #Buttons + 2) then
        return
    end
    local start_row = math.floor((size.rows - #Letters[1] - #Buttons - 2) / 2)
    print_padding_lines(start_row - 1)
    local text_len = 0
    for _, ltr in pairs(Letters) do
        text_len = text_len + vim.fn.strdisplaywidth(ltr[1])
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
    lower = 40,
    higher = 30
}

---@param opts {text: string, hl: string, cb: function, map: string, icon: string}
local function button(size, opts)
    state.set_col = size.padd + 2

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
    local width = vim.fn.strdisplaywidth(opts.text)
    local padd = math.floor((size.cols - width) / 2)
    print_hl_line(opts.text, "Startscreen" .. opts.hl, padd)
end

local function draw_screen()
    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, {})
    state.cur_row = 0
    state.cur_col = 0
    state.first_editable = 0
    state.was_newline = false
    line_handlers = {}

    local cols = vim.api.nvim_win_get_width(state.win)
    local rows = vim.api.nvim_win_get_height(state.win)
    local target = cols > target_widths.lim and target_widths.higher or target_widths.lower
    local padd = math.floor((cols - target) / 2)

    local size = {
        cols = cols,
        rows = rows,
        target = target,
        padd = padd
    }

    draw_logo(size)
    print_padding_lines(2)
    state.first_editable = state.cur_row + 1

    vim.tbl_map(function(btn) button(size, btn) end, Buttons)

    state.last_editable = state.cur_row
    if rows > state.cur_row + 2 then
        print_padding_lines(rows - state.cur_row - 2)
        centered_text(size, { text = M.texts[(vim.fn.rand() % #M.texts) + 1], hl = "Text" })
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
    state.buf = vim.api.nvim_get_current_buf()
    state.win = vim.api.nvim_get_current_win()
    state.ns = vim.api.nvim_create_namespace("Startscreen")
    state.augroup = vim.api.nvim_create_augroup("Startscreen", {})

    for k, v in pairs(saved_opts) do
        vim.wo[state.win][0][k] = v
    end

    vim.bo[0].buftype = "nofile"
    vim.bo[0].buflisted = false

    -- constrain cursor
    vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = state.buf,
        group = state.augroup,
        callback = function(ctx)
            local pos = vim.api.nvim_win_get_cursor(0)
            local row
            if pos[1] <= state.first_editable then
                row = state.first_editable
            elseif pos[1] >= state.last_editable then
                row = state.last_editable
            else
                row = pos[1]
            end
            vim.fn.setcursorcharpos(row, state.set_col)
        end
    })

    vim.api.nvim_create_autocmd({ "WinResized" }, {
        group = state.augroup,
        callback = draw_screen,
    })

    vim.api.nvim_create_autocmd({ "BufWinLeave", "BufHidden" }, {
        buffer = state.buf,
        once = true,
        group = state.augroup,
        callback = function(ctx)
            vim.api.nvim_del_augroup_by_id(state.augroup)
            vim.defer_fn(function()
                vim.api.nvim_buf_delete(state.buf, { force = true })
            end, 10)
        end
    })

    vim.keymap.set("n", "<CR>", function()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        if line_handlers[row] then
            line_handlers[row]()
        end
    end, { buffer = state.buf })

    draw_screen()
end

M.texts = {
    "Never :q me for emacs",
    "Don't forget to take breaks when vimming",
    "Prefer using :h text-objects over motions",
    "Enjoy your day!",
    ":3",
    "Tired? Just <C-z>",
    ":v == :g!",
}


return M
