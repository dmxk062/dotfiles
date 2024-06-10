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
    vim.cmd.normal{cmdstr, bang = true}
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
    cmd("l")
    local previousDiag = vim.diagnostic.get_prev{ wrap = false }
    cmd("h")

    local nextDiag = vim.diagnostic.get_next{ wrap = false }
    local on_prev = false
    local current_row, current_column = unpack(vim.api.nvim_win_get_cursor(0))

    if previousDiag then
        local current_after_previous_start = (current_row == previousDiag.lnum + 1 and current_column >= previousDiag.col)
            or (current_row > previousDiag.lnum + 1)

        local current_before_previous_end = (current_row == previousDiag.end_lnum + 1 and current_column <= previousDiag.end_col - 1)
            or (current_row < previousDiag.end_lnum)

        on_prev =  current_after_previous_start and current_before_previous_end
    end

    local target = on_prev and previousDiag or nextDiag
    if target then 
        set_visual_selection({target.lnum + 1, target.col}, {target.end_lnum + 1, target.end_col - 1})
    end
end

return M
