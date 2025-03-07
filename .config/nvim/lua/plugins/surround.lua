local M = {
    "kylechui/nvim-surround",
    event = "VeryLazy"
}

local function generic_pair(left, right)
    local esc_left, esc_right = vim.pesc(left), vim.pesc(right)
    local cdelete = string.format("^(%s)().-(%s)()$", esc_left, esc_right)
    return {
        add = { left, right },
        find = string.format("%s.-%s", esc_left, esc_right),
        delete = cdelete,
        change = {
            target = cdelete
        }
    }
end

-- Foldmarkers {{{
local function getline(line)
    return vim.api.nvim_buf_get_lines(0, line, line + 1, false)[1]
end

local function get_foldmarker_area()
    local marker = vim.opt.foldmarker:get()

    local startpattern = vim.pesc(marker[1])
    local endpattern = vim.pesc(marker[2])
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local startline, endline
    local maxlines = vim.api.nvim_buf_line_count(0)

    startline = line
    local found_start_behind = true
    while not getline(startline):find(startpattern) do
        startline = startline - 1
        if startline <= 1 then
            found_start_behind = false
            break
        end
    end
    if not found_start_behind then
        startline = line
        while not getline(startline):find(startpattern) do
            startline = startline + 1
            if startline >= maxlines then
                return
            end
        end
    end

    startline = startline + 1

    endline = line
    while not getline(endline):find(endpattern) do
        endline = endline + 1
        if endline >= maxlines then
            return
        end
    end
    endline = endline + 1

    return {
        { startline, 1 },
        { endline,   #getline(endline - 1) },
    }
end

local surround_fold = {
    add = function()
        local marker = vim.opt.foldmarker:get()
        local name = require("nvim-surround.config").get_input("Fold Title: ")
        if not name then
            return
        end
        local commentstring = vim.o.commentstring
        return {
            { commentstring:format(name .. " " .. marker[1]), "" },
            { "",                                             commentstring:format(marker[2]) }
        }
    end,
    find = function()
        local area = get_foldmarker_area()
        if not area then
            return
        end

        return { first_pos = area[1], last_pos = area[2] }
    end,
    delete = function()
        local area = get_foldmarker_area()
        if not area then
            return
        end

        return {
            left = {
                first_pos = area[1],
                last_pos = { area[1][1] + 1, 0 },
            },
            right = {
                first_pos = { area[2][1], 0 },
                last_pos = { area[2][1] + 1, 0 },
            }
        }
    end,
    change = {
        target = function()
            local area = get_foldmarker_area()
            if not area then
                return
            end

            return {
                left = {
                    first_pos = area[1],
                    last_pos = { area[1][1], #getline(area[1][1]) },
                },
                right = {
                    first_pos = { area[2][1], 0 },
                    last_pos = area[2]
                }
            }
        end
    }
}

-- }}}

M.opts = {
    surrounds = {
        -- variable expansion
        ["v"] = generic_pair("${", "}"),
        -- subshell expansion
        ["x"] = generic_pair("$(", ")"),
        -- lua table key
        ["k"] = generic_pair('["', '"]'),
        -- folds
        ["z"] = surround_fold,
    }
}

return M
