local M = {}
local api = vim.api
local esc = api.nvim_replace_termcodes("<esc>", true, false, true)

--[[ Rationale {{{
see https://github.com/chrisgrieser/nvim-various-textobjs

This will be nowhere near as complex, I just want a framework to my own
see ./operators.lua as well

Important ones:
 - indent: ii, ai, aI
 - diagnostics: id, iDe, iDw, iDi, iDh
 - arbitrary single-line regexes
 - entire buffer: gG
}}} ]]--

---@alias point [integer, integer]
---@alias region [point, point]
---@alias seltype "line"|"char"
---@alias textobj_function fun(pos: point, lcount: integer, opts: any?): region|point?, seltype?

---@param cmdstr string
local function norm(cmdstr)
    vim.cmd.normal { cmdstr, bang = true }
end

local function cancel_selection()
    if api.nvim_get_mode().mode == "no" then
        api.nvim_feedkeys(esc, "n", false)
    end
end

local function getline(lnum)
    return api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]
end

---@param fn textobj_function
---@param opts table<string, any>
function M.create_textobj(fn, opts)
    return function()
        local curpos = api.nvim_win_get_cursor(0)
        local lcount = api.nvim_buf_line_count(0)
        local sel, mode = fn(curpos, lcount, opts)
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
local function diagnostic(pos, lcount, opts)
    local args = {
        wrap = false,
        cursor_position = pos,
    }

    local prev_diag = vim.diagnostic.get_prev(args)
    local on_prev = false
    local next_diag = vim.diagnostic.get_next(args)

    if prev_diag then
        local cur_after_prev_start = (pos[1] == prev_diag.lnum + 1 and pos[2] >= prev_diag.col) or
            (pos[1] > prev_diag.lnum + 1)

        local cur_befor_prev_end = (pos[1] == prev_diag.end_lnum + 1 and pos[1] <= prev_diag.end_col - 1) or
            (pos[1] < prev_diag.end_lnum)

        on_prev = cur_after_prev_start and cur_befor_prev_end
    end

    local target = on_prev and prev_diag or next_diag

    if target then
        if opts.type then
            local diagtype = target.severity
            if diagtype ~= opts.type then
                return diagnostic({ target.end_lnum + 2, target.end_col + 2 }, lcount, opts)
            end
        end
        return { { target.lnum + 1, target.col }, { target.end_lnum + 1, target.end_col - 1 } }, "char"
    end

    return nil, nil
end

M.diagnostic = M.create_textobj(diagnostic, { type = nil })
M.diagnostic_error = M.create_textobj(diagnostic, { type = vim.diagnostic.severity.ERROR })
M.diagnostic_warn = M.create_textobj(diagnostic, { type = vim.diagnostic.severity.WARN })
M.diagnostic_info = M.create_textobj(diagnostic, { type = vim.diagnostic.severity.INFO })
M.diagnostic_hint = M.create_textobj(diagnostic, { type = vim.diagnostic.severity.HINT })

local function line_is_blank(lnum)
    local line = getline(lnum)
    return line:find("^%s*$") ~= nil
end

-- filetypes for which outer indentation should only be applied to lines above by default
-- this is only due to language syntax and might not 100% be reliable
-- e.g. multiline lists/maps in python
--
-- to force both, use `aI`(current mapping), this also works in other filetypes,
-- so use that for macros to force that behavior
M.indent_only_before = {
    python   = true,
    norg     = true,
    markdown = true,
    asm      = true,
    lisp     = true,
    yuck     = true,
}

local function indent(pos, lcount, opts)
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

    if opts.outer and not opts.always_last and M.indent_only_before[vim.bo[0].ft] then
        nextl = nextl - 1
    end
    if not opts.outer then
        prevl = prevl + 1
        nextl = nextl - 1
    end

    if nextl > lcount then
        nextl = lcount
    end

    while line_is_blank(nextl) do
        nextl = nextl - 1
    end

    return { { prevl, 1 }, { nextl, 1 } }, "line"
end

M.indent_inner = M.create_textobj(indent, { outer = false })
M.indent_outer = M.create_textobj(indent, { outer = true })
M.indent_outer_with_last = M.create_textobj(indent, { outer = true, always_last = true })

M.entire_buffer = M.create_textobj(function(pos, lcount, outer)
    return { { 1, 1 }, { lcount, 1 } }, "line"
end, {})

-- search for a pattern, use capture group to specify what to match
-- two capture groups are necessary: an optional prefix and suffix
-- if you don't need prefix and suffix, use ()
local function pattern_obj(pos, lcount, opts)
    local curline = pos[1]
    local curcol = pos[2]

    local line = getline(curline)

    local startpos = 0 ---@type integer?
    local endpos

    local g1, g2

    repeat
        startpos = startpos + 1
        startpos, endpos, g1, g2 = line:find(opts.pattern, startpos)
    until not startpos or (endpos and endpos > curcol)

    -- not found in first line
    if not startpos then
        while true do
            if curline > lcount then
                return
            end
            curline = curline + 1
            line = getline(curline)
            startpos, endpos, g1, g2 = line:find(opts.pattern)
            if startpos then
                break
            end
        end
    end

    if not startpos then
        return
    end

    local obj_start = (type(g1) ~= "number" and #g1 or 0) + startpos
    local obj_end = endpos - (type(g2) ~= "number" and #g2 or 0)
    return { { curline, obj_start - 1 }, { curline, obj_end - 1 } }, "char"
end

function M.create_pattern_obj(pattern)
    return M.create_textobj(pattern_obj, { pattern = pattern })
end

return M
