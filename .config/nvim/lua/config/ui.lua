local M = {}
local api = vim.api
local ns = api.nvim_create_namespace("config.ui.ui")
local hlns = api.nvim_create_namespace("config.ui.hl")

-- Form Widget {{{

---@class config.ui.form.entry
---@field name string
---@field key string
---@field type string "int"|"float"|"bool"|"string"
---@field initial string?

---@class config.ui.form.opts
---@field title string
---@field on_completed fun(values: table<string, any>)
---@field entries config.ui.form.entry[]

---@class config.ui.form.state
---@field win integer
---@field buf integer
---@field entries config.ui.form.entry[]
---@field values table<string, string>

---@type (fun(str: string): boolean)[]
local builtin_validators = {
    int = function(str)
        return str:match("^%-?%s*%d+%s*$") and true or false
    end,
    float = function(str)
        return str:match("^%s*%-?%d+%.?%d*%s*$") and true or false
    end,
    bool = function(str)
        local keywords = {
            ["true"] = true,
            ["false"] = true,
            ["on"] = true,
            ["off"] = true,
            ["yes"] = true,
            ["no"] = true
        }
        return keywords[vim.trim(str)]
    end,
    string = function(str)
        return true
    end
}

local type_hl_groups = {
    int = "Number",
    float = "Number",
    string = "String",
    bool = "Boolean",
}

---@param state config.ui.form.state
---@param validate boolean
---@param start number
---@param stop number
local function form_highlight_and_validate(state, validate, start, stop)
    local buf = state.buf

    local lines = api.nvim_buf_get_lines(buf, start - 1, stop - 1, false)
    api.nvim_buf_clear_namespace(buf, hlns, start - 1, stop - 1)

    for i, line in ipairs(lines) do
        local row = start + i - 2

        local entry = state.entries[row + 1]
        local typ = entry.type
        local hlgroup = "DiagnosticError"
        if not validate or builtin_validators[typ](line) then
            hlgroup = type_hl_groups[typ]
            state.values[entry.key] = line
        end

        api.nvim_buf_set_extmark(buf, hlns, row, 0, {
            end_row = row,
            end_col = #line,
            hl_group = hlgroup
        })
    end
end

local parsers = {
    int = function(s)
        return math.floor(tonumber(s, 10))
    end,
    float = tonumber,
    bool = function(s)
        if s == "true" or s == "yes" or s == "on" then
            return true
        elseif s == "false" or s == "no" or s == "off" then
            return false
        end

        return nil
    end,
    string = function(s)
        return s:gsub("\\n", "\n"):gsub("\\t", "\t")
    end
}

---@param state config.ui.form.state
local function form_parse_values(state)
    local res = {}
    for _, entry in ipairs(state.entries) do
        res[entry.key] = parsers[entry.type](state.values[entry.key])
    end

    return res
end

local function form_select(state, row)
    if row < 1 or row > api.nvim_buf_line_count(state.buf) then
        return
    end

    local content = api.nvim_buf_get_lines(state.buf, row - 1, row, false)[1]
    api.nvim_win_set_cursor(state.win, { row, 0 })

    api.nvim_feedkeys("\x1bgh", "n")
    vim.schedule(function()
        api.nvim_win_set_cursor(state.win, {
            row,
            #content - 1,
        })
    end)
end

---@param opts config.ui.form.opts
M.form = function(opts)
    local buf = api.nvim_create_buf(false, true)

    local entries = opts.entries
    local height = #entries

    local win = api.nvim_open_win(buf, true, {
        title = opts.title,
        title_pos = "center",
        relative = "cursor",
        style = "minimal",
        height = height,
        width = 30,
        row = 2,
        col = -1,
    })


    for i, entry in ipairs(entries) do
        local row = i - 1
        api.nvim_buf_set_text(buf, row, 0, row, 0, { entry.initial or "", "" })
        api.nvim_buf_set_extmark(buf, ns, row, -1, {
            virt_text = { { entry.name, "Normal" } },
            virt_text_pos = "eol_right_align",
        })
    end

    ---@type config.ui.form.state
    local state = {
        buf = buf,
        win = win,
        entries = entries,
        values = {}
    }

    api.nvim_buf_set_lines(buf, -2, -1, false, {}) -- remove last line
    api.nvim_win_set_cursor(win, { 1, 0 })
    form_highlight_and_validate(state, false, 1, height + 1)

    local map = function(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = buf })
    end

    local accept = function()
        local values = form_parse_values(state)
        api.nvim_buf_delete(buf, { force = true })
        opts.on_completed(values)
    end
    map("n", "<cr>", accept)
    map({ "n", "s", "i", "v" }, "<Tab>", function()
        form_select(state, api.nvim_win_get_cursor(state.win)[1] + 1)
    end)
    map({ "n", "s", "v" }, "n", function()
        form_select(state, api.nvim_win_get_cursor(state.win)[1] + 1)
    end)
    map({ "n", "s", "i", "v" }, "<S-Tab>", function()
        form_select(state, api.nvim_win_get_cursor(state.win)[1] - 1)
    end)
    map({ "n", "s", "v" }, "N", function()
        form_select(state, api.nvim_win_get_cursor(state.win)[1] - 1)
    end)


    api.nvim_buf_attach(buf, true, {
        on_lines = function(_, b, _, first, last)
            form_highlight_and_validate(state, true, first + 1, last + 1)
        end
    })

    form_select(state, 1)
end
-- }}}

return M
