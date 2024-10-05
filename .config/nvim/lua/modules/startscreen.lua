local M = {}

local state = {
    buf = 0,
    win = 0,
    cur_row = 0,
    cur_col = 0,
    ns = 0,
    augroup = 0,
    first_editable = 0,
    was_newline = false,
    set_col = 0,
    saved = {

    }
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
        map = "H",
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

---@param opts {text: string, hl: string, cb: function, map: string, icon: string}
local function button(size, opts)
    local target_width = size.cols > 46 and 40 or 30

    local initial_padd = math.floor((size.cols - target_width) / 2)
    state.set_col = initial_padd + 2

    line_handlers[state.cur_row + 1] = opts.cb
    local text = opts.icon .. " " .. opts.text
    local text_len = #opts.text + 2 -- assume icon always has length 1
    print_hl_line(text, "Startscreen" .. opts.hl, initial_padd, false)

    local mapping = "<" .. opts.map .. ">"
    local missing_padd = (target_width - (text_len))

    print_hl_line(mapping, "Startscreen" .. opts.hl, missing_padd, true)

    vim.keymap.set("n", opts.map, opts.cb, { buffer = state.buf })
end


local function draw_screen()
    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, {})
    state.cur_row = 0
    state.cur_col = 0
    state.first_editable = 0
    state.was_newline = false
    line_handlers = {}

    local size = {
        cols = vim.api.nvim_win_get_width(state.win),
        rows = vim.api.nvim_win_get_height(state.win),
    }

    draw_logo(size)
    print_padding_lines(2)
    state.first_editable = state.cur_row + 1

    vim.tbl_map(function(btn) button(size, btn) end, Buttons)


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
        state.saved[k] = vim.wo[state.win][k]
        vim.wo[state.win][k] = v
    end

    -- constrain cursor
    vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = state.buf,
        group = state.augroup,
        callback = function(ctx)
            local pos = vim.api.nvim_win_get_cursor(0)
            local row
            if pos[1] <= state.first_editable then
                row = state.first_editable
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

            for k, v in pairs(state.saved) do
                vim.wo[state.win][k] = v
                vim.wo[0][k] = v
            end

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

return M
