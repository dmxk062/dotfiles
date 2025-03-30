--[[ Description {{{
Improvements to core nvim concepts, to enhance them while keeping functionality
}}} ]]

local M = {}
local api = vim.api


--[[ Highlighting fFtF {{{
Welcome to the greatest HACK of my life
]]

local find_ns = api.nvim_create_namespace("config.highlight_find")
local function highlight_motion(cmd)
    local goes_backward = cmd == "F" or cmd == "T"
    local cursor = api.nvim_win_get_cursor(0)
    local line = api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], false)[1]

    local index = 1
    local lastwasword = false
    local lastwascap = false

    local seen = {}
    local count = vim.v.count1
    --[[
    Highlight the following: 
        - non alphanumeric characters
        - first capital character in a sequence
        - first character of word
    ]]
    for i = cursor[2] + (goes_backward and 0 or 2), (goes_backward and 1 or #line), (goes_backward and -1 or 1) do
        local char = line:sub(i, i)
        seen[char] = (seen[char] or 0) + 1
        local isalpha = char:lower() ~= char:upper()
        local iscap = char:upper() == char

        if not isalpha or (isalpha and not lastwasword) or (iscap and not lastwascap) then
            if seen[char] == count then
                api.nvim_buf_set_extmark(0, find_ns, cursor[1] - 1, i - 1, {
                    hl_group = "FindFirst" .. index % 9,
                    end_col = i,
                    end_line = cursor[1] - 1,
                })
                index = index + 1
            end
        end

        lastwasword = isalpha
        lastwascap = iscap
    end
end

M.highlight_find = function(cmd)
    highlight_motion(cmd)

    -- we're in some "normal-ish" mode, no weird scheduling hacks
    if vim.api.nvim_get_mode().mode ~= "no" then
        api.nvim_feedkeys(vim.v.count1 .. cmd, "n")
        -- as soon as the key is typed, we're done
        vim.on_key(function(key, typed)
            api.nvim_buf_clear_namespace(0, find_ns, 0, -1)
            vim.on_key(nil, find_ns)
        end, find_ns)
    else
        -- here be dragons
        local op = vim.v.operator
        -- give it time to highlight
        vim.defer_fn(function()

            -- no better event
            api.nvim_create_autocmd("ModeChanged", {
                callback = function(ev)
                    if vim.v.event.old_mode == "no" then
                        api.nvim_buf_clear_namespace(0, find_ns, 0, -1)
                        return true
                    end
                end
            })

            -- make sure that custom operators work
            api.nvim_feedkeys(op, "")
            -- so feed the motion separately
            api.nvim_feedkeys(vim.v.count1 .. cmd, "n")
        end, 10)
    end

    -- make ; and , work with this
    require("nvim-treesitter.textobjects.repeatable_move").last_move = {
        func = cmd,
        opts = { forward = cmd == "f" or cmd == "t" }
    }
end
-- }}}

return M
