-- my own mark handling

---@class marks_bufstate
---@field ns integer
---@field target_buf integer
---@field render_buf integer
---@field render_win integer
---@field gmarks [integer, integer, integer, string]?
---@field lmarks [integer, integer]?
---@field prev_lines string[]
---@field marks_for_lines table<integer, table>
---@field found_old_marks table<string, boolean>

local M = {}
local api = vim.api

local popup_is_open = false

local lowercase = {}
for i = 97, 122 do
    table.insert(lowercase, string.char(i))
end
local uppercase = {}
for i = 65, 90 do
    table.insert(uppercase, string.char(i))
end

local function getmarks(buf)
    local gmarks = {}
    local lmarks = {}
    for _, letter in pairs(lowercase) do
        local m = api.nvim_buf_get_mark(buf, letter)
        if m[1] ~= 0 then
            lmarks[letter] = m
        end
    end
    for _, letter in pairs(uppercase) do
        local m = api.nvim_get_mark(letter, {})
        if m[1] ~= 0 then
            gmarks[letter] = m
        end
    end
    return gmarks, lmarks
end

---@param state marks_bufstate
local function render_buf(state)
    api.nvim_buf_clear_namespace(state.render_buf, state.ns, 0, -1)
    api.nvim_buf_set_lines(state.render_buf, 0, -1, false, {})

    state.marks_for_lines = {}
    local gmarks, lmarks = getmarks(state.target_buf)
    state.gmarks = gmarks
    state.lmarks = lmarks

    local i = 0
    for name, mark in pairs(gmarks) do
        state.marks_for_lines[i] = name
        state.found_old_marks[name] = false

        local path = vim.fn.fnamemodify(mark[4]:gsub("oil://", ""), ":~:.")
        local pos = string.format("%3d:%2d", mark[1], mark[2])
        local line = name .. " " .. pos .. " " .. path
        state.prev_lines[i] = line

        api.nvim_buf_set_lines(state.render_buf, i, i, false, { line })

        -- grey out unloaded buffers
        if mark[3] == 0 then
            api.nvim_buf_add_highlight(state.render_buf, state.ns, "MarkUnloaded", i, 3 + #pos, -1)
        end
        api.nvim_buf_add_highlight(state.render_buf, state.ns, "MarkGlobal", i, 0, 1)

        api.nvim_buf_add_highlight(state.render_buf, state.ns, "MarkPosition", i, 2, 2 + #pos)

        i = i + 1
    end

    for name, mark in pairs(lmarks) do
        state.marks_for_lines[i] = name
        state.found_old_marks[name] = false

        local line = string.format("%s %3d:%2d", name, mark[1], mark[2])

        state.prev_lines[i] = line
        api.nvim_buf_set_lines(state.render_buf, i, i, false, { line })

        api.nvim_buf_add_highlight(state.render_buf, state.ns, "MarkLocal", i, 0, 1)
        api.nvim_buf_add_highlight(state.render_buf, state.ns, "MarkPosition", i, 2, -1)

        -- show a preview of the line
        api.nvim_buf_set_extmark(state.render_buf, state.ns, i, #line, {
            virt_text = {
                {
                    (mark[2] ~= 0 and "..." or "" ) .. api.nvim_buf_get_text(
                        state.target_buf, mark[1] - 1, mark[2], mark[1] - 1, -1, {}
                    )[1]:gsub("^%s*", ""),
                    "MarkPreview"
                }
            }
        })

        i = i + 1
    end

    api.nvim_win_set_cursor(state.render_win, { 1, 0 })
    vim.bo[state.render_buf].modified = false
end

---@param state marks_bufstate
local function parse_buffer(state)
    local lines = api.nvim_buf_get_lines(state.render_buf, 0, -1, false)
    for i, line in ipairs(lines) do
        if line:match("^%s*$") then
            goto continue
        end

        local rstart, rend, mark = line:find("^%s*(%a)%s*")
        local isglobal = mark:upper() == mark
        if not rstart or not rend then
            vim.notify("markeditor: Missing mark on line: " .. i + 1)
            return false
        end
        state.found_old_marks[mark] = true

        if line == state.prev_lines[i - 1] then
            goto continue
        end


        local rest = line:sub(rend + 1, -1)

        if isglobal then
            local _, _, frow, fcolumn, file = rest:find("^(%d*)%s*:?%s*(%d*)%s*(%S+)")
            if file then
                local column, row = 1, 1
                if frow and fcolumn then
                    row = tonumber(frow) or 1
                    column = tonumber(fcolumn) or 1
                end

                local buf = vim.fn.bufadd(vim.fn.expand(file))
                api.nvim_buf_set_mark(buf, mark, row, column, {})
            else
                vim.notify("markeditor: Missing file for global mark on line: " .. i, vim.log.levels.ERROR)
                return false
            end
        else
            local _, _, frow, fcolumn = rest:find("(%d*)%s*:%s*(%d*)")
            if frow then
                local column, row = 1, 1
                if frow or fcolumn then
                    row = tonumber(frow) or 1
                    column = tonumber(fcolumn) or 1
                end

                api.nvim_buf_set_mark(state.target_buf, mark, row, column, {})
            else
                vim.notify("markeditor: Missing range for local mark on line: " .. i, vim.log.levels.ERROR)
                return false
            end
        end


        ::continue::
    end

    for m, found in pairs(state.found_old_marks) do
        if not found then
            if m:upper() == m then
                api.nvim_del_mark(m)
            else
                api.nvim_buf_del_mark(state.target_buf, m)
            end
        end
    end

    state.prev_lines = {}
    state.found_old_marks = {}
    return true
end

function M.marks_popup()
    if popup_is_open then
        return
    end
    popup_is_open = true

    local curbuf = api.nvim_get_current_buf()
    local buf = api.nvim_create_buf(false, true)

    local win_width = api.nvim_win_get_width(0)
    local win_height = api.nvim_win_get_height(0)

    local width = win_width >= 48 and 50 or win_width - 2
    local height = win_height >= 10 and 8 or win_height - 2

    local target_col = math.floor((win_width - width) / 2)
    local target_row = math.floor((win_height - height) / 2)
    local win = api.nvim_open_win(buf, true, {
        border = "rounded",
        relative = "win",
        title = "Marks",
        title_pos = "center",
        width = width,
        height = height,
        row = target_row,
        col = target_col,
    })

    vim.bo[buf].buftype = "acwrite"
    vim.bo[buf].bufhidden = "hide"
    vim.wo[win][0].wrap = false
    api.nvim_buf_set_name(buf, "marks")

    ---@type marks_bufstate
    local state = {
        render_buf = buf,
        render_win = win,
        target_buf = curbuf,
        marks_for_lines = {},
        prev_lines = {},
        found_old_marks = {},
        ns = api.nvim_create_namespace("markeditor"),
    }


    local function open_mark(precmd)
        local mark = state.marks_for_lines[api.nvim_win_get_cursor(win)[1] - 1]
        if not mark then
            return
        end
        api.nvim_win_close(win, true)
        vim.cmd((precmd and precmd .. "|" or "") .. "'" .. mark)
    end

    local map = require("utils").local_mapper(buf)
    map("n", "<cr>", function() open_mark() end)
    map("n", "v", function() open_mark("vsplit") end)
    map("n", "s", function() open_mark("split") end)
    map("n", "t", function() open_mark("tabnew") end)

    for i = 1, 9 do
        map("n", tostring(i), function()
            pcall(api.nvim_win_set_cursor, win, { i, 0 })
        end)
    end

    local augroup = api.nvim_create_augroup("markeditor", { clear = true })
    api.nvim_create_autocmd("BufWriteCmd", {
        buffer = buf,
        group = augroup,
        callback = function(ctx)
            if parse_buffer(state) then
                render_buf(state)
            end
        end
    })
    api.nvim_create_autocmd("WinClosed", {
        buffer = buf,
        once = true,
        group = augroup,
        callback = function(ctx)
            api.nvim_buf_delete(buf, { force = true })
            api.nvim_del_augroup_by_id(augroup)
            popup_is_open = false
        end
    })

    render_buf(state)
end

function M.set_first_avail_gmark()
    for _, mark in pairs(uppercase) do
        local mark_res = api.nvim_buf_get_mark(0, mark)
        if mark_res[1] == 0 then
            vim.cmd("normal! m" .. mark)
            print(mark)
            return
        end
    end
end

function M.set_first_avail_lmark()
    for _, mark in pairs(lowercase) do
        local mark_res = api.nvim_buf_get_mark(0, mark)
        if mark_res[1] == 0 then
            vim.cmd("normal! m" .. mark)
            print(mark)
            return
        end
    end
end

return M
