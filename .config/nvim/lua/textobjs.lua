-- see https://github.com/chrisgrieser/nvim-various-textobjs
-- nowhere near as complex, but i just want some framework for making my own

local M = {}

---@param name string
---@param delim string
function M.create_delim_obj(name, delim)
    vim.keymap.set({ "x", "o" },
        "i" .. name,
        "<cmd>normal! T" .. delim .. "vt" .. delim .. "<CR>",
        { silent = true, noremap = true }
    )
    vim.keymap.set({ "x", "o" },
        "a" .. name,
        "<cmd>normal! F" .. delim .. "vf" .. delim .. "<CR>",
        { silent = true, noremap = true }
    )
end

-- more complex objects

local function is_visual()
    return vim.fn.mode():find("v") ~= nil
end

---@param cmdstr string
local function cmd(cmdstr)
    vim.cmd.normal { cmdstr, bang = true }
end

---@alias position {[1]: integer, [2]: integer}

---@param startpos position
---@param endpos position
local function set_visual_selection(startpos, endpos)
    cmd("m`") -- set mark
    vim.api.nvim_win_set_cursor(0, startpos)
    if is_visual() then
        cmd("o")
    else
        cmd("v")
    end
    vim.api.nvim_win_set_cursor(0, endpos)
end

function M.diagnostic()
    -- position is off by one
    -- see https://github.com/chrisgrieser/nvim-various-textobjs/blob/main/lua/various-textobjs/charwise-textobjs.lua
    cmd("l")
    local previous_diag = vim.diagnostic.get_prev { wrap = false }
    cmd("h")

    local next_diag = vim.diagnostic.get_next { wrap = false }
    local on_prev = false
    local cursor_row, cursor_column = unpack(vim.api.nvim_win_get_cursor(0))

    if previous_diag then
        local current_after_previous_start = (cursor_row == previous_diag.lnum + 1 and cursor_column >= previous_diag.col)
            or (cursor_row > previous_diag.lnum + 1)

        local current_before_previous_end = (cursor_row == previous_diag.end_lnum + 1 and cursor_column <= previous_diag.end_col - 1)
            or (cursor_row < previous_diag.end_lnum)

        on_prev = current_after_previous_start and current_before_previous_end
    end

    local target = on_prev and previous_diag or next_diag
    if target then
        set_visual_selection({ target.lnum + 1, target.col }, { target.end_lnum + 1, target.end_col - 1 })
    end
end

---@param linenum integer
local function getline(linenum)
    return vim.api.nvim_buf_get_lines(0, linenum - 1, linenum, true)[1]
end

---@param pattern string
---@return position? startpos
---@return position? endpos
local function find_pattern(pattern)
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = getline(cursor_row)
    local lastline = vim.api.nvim_buf_line_count(0)
    local begin_col = 0 ---@type integer|nil
    local end_col, none_in_first

    repeat
        begin_col = begin_col + 1
        begin_col, end_col, _, _ = line:find(pattern, begin_col)
        none_in_first = not begin_col
        local on_or_infront = end_col and end_col > cursor_col
    until on_or_infront or none_in_first

    local searched = 0

    if none_in_first then
        while true do
            searched = searched + 1
            if cursor_row + searched > lastline then return end

            line = getline(cursor_row + searched)
            begin_col, end_col, _, _ = line:find(pattern, begin_col)
            if begin_col then break end
        end
    end

    local startpos = { cursor_row + searched, begin_col - 1 }
    local endpos   = { cursor_row + searched, end_col - 1 }

    return startpos, endpos
end

---select a pattern, regex
---@param pattern string
function M.pattern(pattern)
    local startpos, endpos = find_pattern(pattern)
    if not (startpos and endpos) then
        return
    end

    set_visual_selection(startpos, endpos)
end

return M
