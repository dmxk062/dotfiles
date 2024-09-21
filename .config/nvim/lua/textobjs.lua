-- see https://github.com/chrisgrieser/nvim-various-textobjs
-- nowhere near as complex, but i just want some framework for making my own

---@param linenum integer
local function getline(linenum)
    return vim.api.nvim_buf_get_lines(0, linenum - 1, linenum, true)[1]
end

---@param cmdstr string
local function cmd(cmdstr)
    vim.cmd.normal { cmdstr, bang = true }
end

---@alias position {[1]: integer, [2]: integer}

---@param startpos position
---@param endpos position
local function set_visual_selection(startpos, endpos, linewise)
    cmd("m`") -- set mark
    vim.api.nvim_win_set_cursor(0, startpos)

    local mode = vim.fn.mode(0)
    if mode:find("v") ~= nil then
        if linewise then
            if mode == "V" then
                cmd("o")
            else
                cmd("V")
                cmd("o")
            end
        else
            cmd("o")
        end
    else
        if linewise then
            cmd("V")
        else
            cmd("v")
        end
    end
    vim.api.nvim_win_set_cursor(0, endpos)
end

local function cancel_selection()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", false)
end

---@param _type "error"|"warn"|"info"|"hint"|nil
---@param pos position|nil
local function diagnostic(_type, pos)
    local types = {
        error = 1,
        warn = 2,
        info = 3,
        hint = 4,
    }
    local type = types[_type]
    local opts = { wrap = false, cursor_position = pos or vim.api.nvim_win_get_cursor(0) }

    -- position is off by one
    -- see https://github.com/chrisgrieser/nvim-various-textobjs/blob/main/lua/various-textobjs/charwise-textobjs.lua
    cmd("l")
    local previous_diag = vim.diagnostic.get_prev(opts)
    cmd("h")

    local next_diag = vim.diagnostic.get_next(opts)
    local on_prev = false
    local cursor_row, cursor_col = unpack(opts.cursor_position)

    if previous_diag then
        local current_after_previous_start = (cursor_row == previous_diag.lnum + 1 and cursor_col >= previous_diag.col)
            or (cursor_row > previous_diag.lnum + 1)

        local current_before_previous_end = (cursor_row == previous_diag.end_lnum + 1 and cursor_col <= previous_diag.end_col - 1)
            or (cursor_row < previous_diag.end_lnum)

        on_prev = current_after_previous_start and current_before_previous_end
    end

    local target = on_prev and previous_diag or next_diag
    if target then
        if type ~= nil then
            local diagtype = target.severity
            if diagtype ~= type then
                -- didnt find what we were looking for, goto next
                return M.diagnostic(_type, { target.end_lnum + 2, target.end_col + 2 })
            end
        end
        set_visual_selection({ target.lnum + 1, target.col }, { target.end_lnum + 1, target.end_col - 1 })
        return
    end

    cancel_selection()
    return false
end


local function line_is_empty(linenr)
    local line = vim.api.nvim_buf_get_lines(0, linenr - 1, linenr, false)[1]
    return (not line or line == "")
end

---@param around boolean
local function indent(around)
    local startline = vim.api.nvim_win_get_cursor(0)[1]
    if line_is_empty(startline) then
        startline = startline + 1
    end

    local target_indent = vim.fn.indent(startline)
    local linecount = vim.api.nvim_buf_line_count(0)

    local endline = startline
    local start_included, end_included
    while true do
        local level = vim.fn.indent(endline)
        if endline == linecount then
            if level >= target_indent then end_included = true end
            break
        end

        if level < target_indent then
            if not (line_is_empty(endline) and vim.fn.indent(endline + 1) >= target_indent) then
                break
            end
        end

        endline = endline + 1
    end

    while true do
        local level = vim.fn.indent(startline)
        if startline == 1 then
            if level >= target_indent then start_included = true end
            break
        end

        if level < target_indent then
            if not (line_is_empty(startline) and vim.fn.indent(startline - 1) >= target_indent) then
                break
            end
        end

        startline = startline - 1
    end

    if not around then
        if not (startline == 1 and start_included) then
            startline = startline + 1
        end
        if not end_included then
            endline = endline - 1
        end
    end

    set_visual_selection({ startline, 0 }, { endline, 0 }, true)
end


local function leap_get_point(cb)
    local curwin = vim.api.nvim_get_current_win()
    require("leap").leap {
        target_windows = { curwin },
        action = function(target1)
            require("leap").leap {
                target_windows = { curwin },
                action = function(target2)
                    cb(target1, target2)
                end
            }
        end
    }
end

--- Selects the region between two leap targets
--- Basically allows you to select any arbitrary region on the screen
local function leap_selection(outer)
    leap_get_point(function(t1, t2)
        local pos1, pos2
        -- coordinates given by leap are 0 indexed
        if not outer then
            pos1 = { t1.pos[1], t1.pos[2] }
            pos2 = { t2.pos[1], t2.pos[2] - 2 }
        else
            pos1 = { t1.pos[1], t1.pos[2] - 1 }
            pos2 = { t2.pos[1], t2.pos[2] - 1 }
        end
        set_visual_selection(pos1, pos2)
    end)
end

return {
    indent = indent,
    diagnostic = diagnostic,
    leap_selection = leap_selection,
}
