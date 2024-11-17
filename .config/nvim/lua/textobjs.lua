-- see https://github.com/chrisgrieser/nvim-various-textobjs
-- nowhere near as complex, but i just want some framework for making my own
local M = {}
local api = vim.api
local esc = api.nvim_replace_termcodes("<esc>", true, false, true)

---@alias point [integer, integer]
---@alias region [point, point]
---@alias seltype "line"|"char"
---@alias textobj_function fun(pos: point, lcount: integer, outer:boolean, extra: any?): region|point?, seltype?

---@param cmdstr string
local function norm(cmdstr)
    vim.cmd.normal { cmdstr, bang = true }
end

local function cancel_selection()
    if api.nvim_get_mode().mode == "no" then
        api.nvim_feedkeys(esc, "n", false)
    end
end

---@param fn textobj_function
---@param outer boolean
---@param extra any?
function M.create_textobj(fn, outer, extra)
    return function()
        local curpos = api.nvim_win_get_cursor(0)
        local lcount = api.nvim_buf_line_count(0)
        local sel, mode = fn(curpos, lcount, outer, extra)
        if (not sel) or (not mode) then
            cancel_selection()
            return
        end

        norm("m`")
        ---@cast mode seltype
        -- motion
        if type(sel[1]) == "number" then
            ---@cast sel point
            api.nvim_win_set_cursor(0, sel)

            -- textobj
        else
            ---@cast sel region
            local vimode = api.nvim_get_mode().mode
            api.nvim_win_set_cursor(0, sel[1])

            local isvisreg = vimode:find("v")
            local isvisline = vimode:find("V")
            local isvis = isvisreg or isvisline
            local linewise = mode == "line"

            if isvisreg and linewise then
                norm("V")
            end

            if isvis then
                norm("o")
            else
                if linewise then norm("V") else norm("v") end
            end

            api.nvim_win_set_cursor(0, sel[2])
        end
    end
end

---@type textobj_function
local function diagnostic(pos, lcount, outer, type)
    local opts = {
        wrap = false,
        cursor_position = pos,
    }

    local prev_diag = vim.diagnostic.get_prev(opts)
    local on_prev = false
    local next_diag = vim.diagnostic.get_next(opts)

    if prev_diag then
        local cur_after_prev_start = (pos[1] == prev_diag.lnum + 1 and pos[2] >= prev_diag.col) or
            (pos[1] > prev_diag.lnum + 1)

        local cur_befor_prev_end = (pos[1] == prev_diag.end_lnum + 1 and pos[1] <= prev_diag.end_col - 1) or
            (pos[1] < prev_diag.end_lnum)

        on_prev = cur_after_prev_start and cur_befor_prev_end
    end

    local target = on_prev and prev_diag or next_diag

    if target then
        if type ~= nil then
            local diagtype = target.severity
            if diagtype ~= type then
                return diagnostic({ target.end_lnum + 2, target.end_col + 2 }, lcount, outer, type)
            end
        end
        return { { target.lnum + 1, target.col }, { target.end_lnum + 1, target.end_col - 1 } }, "char"
    end

    return nil, nil
end

M.diagnostic = M.create_textobj(diagnostic, false, nil)
M.diagnostic_error = M.create_textobj(diagnostic, false, vim.diagnostic.severity.ERROR)
M.diagnostic_warn = M.create_textobj(diagnostic, false, vim.diagnostic.severity.WARN)
M.diagnostic_info = M.create_textobj(diagnostic, false, vim.diagnostic.severity.INFO)
M.diagnostic_hint = M.create_textobj(diagnostic, false, vim.diagnostic.severity.HINT)

local function line_is_blank(lnum)
    local line = api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]
    return line:find("^%s*$") ~= nil
end

local function indent(pos, lcount, outer)
    local multiplier = vim.v.count > 1 and (vim.v.count - 1) or 0
    local around = vim.o.shiftwidth * multiplier

    local curl = pos[1]

    while (line_is_blank(curl)) do
        if curl == lcount then
            return
        end
        curl = curl + 1
    end

    local start_indent = vim.fn.indent(curl) - around
    if start_indent == 0 then
        return
    end

    local prevl = curl - 1
    local nextl = curl + 1

    while prevl > 0 and (line_is_blank(prevl) or vim.fn.indent(prevl) >= start_indent) do
        prevl = prevl - 1
    end

    while nextl <= lcount and (line_is_blank(nextl) or vim.fn.indent(nextl) >= start_indent) do
        nextl = nextl + 1
    end


    nextl = nextl - 1
    if not outer then
        prevl = prevl + 1
    end

    if nextl > lcount then
        nextl = lcount
    end

    while line_is_blank(nextl) do
        nextl = nextl - 1
    end

    return { { prevl, 1 }, { nextl, 1 } }, "line"
end

M.indent_inner = M.create_textobj(indent, false)
M.indent_outer = M.create_textobj(indent, true)

M.entire_buffer = M.create_textobj(function(pos, lcount, outer)
    return { { 1, 1 }, { lcount, 1 } }, "line"
end, false)

return M
