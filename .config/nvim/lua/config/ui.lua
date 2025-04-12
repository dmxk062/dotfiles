local M = {}
local api = vim.api
local ns = api.nvim_create_namespace("config.ui.ui")
local hlns = api.nvim_create_namespace("config.ui.hl")
local utils = require("config.utils")

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

-- vim.ui.input {{{
local cur_completion
M.nvim_input_omnifunc = function(start, base)
    local compl = cur_completion
    if not compl then
        return start == 1 and 0 or {}
    end
    if start == 1 then
        return 0
    end

    local parts = vim.split(compl, ",", { plain = true })
    local ret
    if parts[1] == "custom" or parts[1] == "customlist" then
        local func = parts[2]
        if vim.startswith(func, "v:lua.") then
            local lua_to_load = ("return %s(...)"):format(func:sub(7))
            local luafunc, err = loadstring(lua_to_load)
            if not luafunc then
                vim.notify(("Failed to load lua omnifunc '%s': %s"):format(lua_to_load, err), vim.log.levels.ERROR)
                return {}
            end

            ret = luafunc(base, base, vim.fn.strlen(base))
        else
            ret = vim.fn[func](base, base, vim.fn.strlen(base))
        end
        if parts[1] == "custom" then
            ret = vim.split(ret, "\n", { plain = true })
        end

        return ret
    end

    local ok, result = pcall(vim.fn.getcompletion, base, compl)
    if ok then
        return result
    else
        return {}
    end
end

---@param opts {prompt: string?, default: string?, completion: string?, highlight: function()}
---@param callback fun(string?)
M.nvim_input = function(opts, callback)
    local buf = api.nvim_create_buf(false, true)
    local title = (opts.prompt and opts.prompt:gsub("%s*:%s*", "") or "Input") .. ": "

    if opts.default then
        api.nvim_buf_set_lines(buf, 0, 0, false, { opts.default })
    end

    api.nvim_buf_set_name(buf, "[Input]")
    local bo = vim.bo[buf]
    bo.filetype = "Input"
    bo.swapfile = false
    bo.bufhidden = "wipe"
    bo.omnifunc = "v:lua.require'config.ui'.nvim_input_omnifunc"
    cur_completion = opts.completion

    local lines = vim.o.lines
    local columns = vim.o.columns
    local win = api.nvim_open_win(buf, true, {
        title = title,
        relative = "editor",
        anchor = "SW",
        style = "minimal",
        row = lines - 2,
        col = 0,
        width = math.max(40, math.min(16, math.floor(columns * 0.3))),
        height = 1,
    })

    local augroup

    local clean = function()
        api.nvim_del_augroup_by_id(augroup)
        pcall(api.nvim_win_close, win, true)
        pcall(api.nvim_buf_delete, win, { force = true })
    end
    local cancel = function()
        callback(nil)
        clean()
    end
    local confirm = function()
        local text = api.nvim_buf_get_lines(buf, 0, -1, false)[1]
        callback(text)
        clean()
    end

    augroup = utils.autogroup("config.ui.input." .. buf, {
        BufLeave                            = cancel,
        [{ "TextChanged", "TextChangedI" }] = function()
            local txt = api.nvim_buf_get_lines(buf, 0, 1, true)[1]
            local hls = {}

            if type(opts.highlight) == "function" then
                hls = opts.highlight(txt)
            elseif opts.highlight then
                hls = vim.fn[opts.highlight](txt)
            end

            api.nvim_buf_clear_namespace(buf, ns, 0, -1)
            for _, hl in ipairs(hls) do
                api.nvim_buf_set_extmark(buf, ns, 0, hl[1], {
                    end_line = 0,
                    end_col = hl[2],
                    hl_group = hl[3],
                })
            end
        end
    }, { buf = buf })
    local map = function(mode, lhs, rhs, map_opts)
        map_opts = map_opts or {}
        map_opts.buffer = buf
        vim.keymap.set(mode, lhs, rhs, map_opts)
    end

    map({ "i", "n" }, "<cr>", confirm)
    map({ "n" }, "<esc>", confirm)
    map({ "i", "s" }, "<Tab>", "<C-n>", { remap = true })

    if not opts.default then
        vim.cmd.startinsert()
    end
end
-- }}}

return M
