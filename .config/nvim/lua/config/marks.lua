--[[ Rationale {{{
Marks are powerful but somewhat cumbersome in vanilla vim
Despite being very fast (two key strokes for 26 local + global each),
they are hard to introspect and use effectively

This module adds ways to handle them more effectively:
 - <space>m shows an interactive popup that allows marks to be edited
 - builtin ' is overriden to search for local marks in all open buffers
 - create the first possible mark without fear of overriding the already set ones
}}} ]]

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

local popup_win = nil

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

    local drawline = 0

    for name, mark in vim.spairs(lmarks) do
        state.marks_for_lines[drawline] = name
        state.found_old_marks[name] = false

        local line = string.format("%s %3d:%2d", name, mark[1], mark[2])

        state.prev_lines[drawline] = line
        api.nvim_buf_set_lines(state.render_buf, drawline, drawline, false, { line })

        api.nvim_buf_add_highlight(state.render_buf, state.ns, "MarkLocal", drawline, 0, 1)
        api.nvim_buf_add_highlight(state.render_buf, state.ns, "MarkPosition", drawline, 2, -1)

        -- show a preview of the line
        local ok, text = pcall(api.nvim_buf_get_text, state.target_buf, mark[1] - 1, mark[2], mark[1] - 1, -1, {})
        if ok then
            api.nvim_buf_set_extmark(state.render_buf, state.ns, drawline, #line, {
                virt_text = {
                    {
                        (mark[2] ~= 0 and "..." or "") .. text[1]:gsub("^%s*", ""),
                        "MarkPreview"
                    }
                }
            })
        end

        drawline = drawline + 1
    end

    for name, mark in vim.spairs(gmarks) do
        state.marks_for_lines[drawline] = name
        state.found_old_marks[name] = false

        local path = vim.fn.fnamemodify(mark[4]:gsub("oil://", ""), ":~:.")
        -- if inside a dir
        if path == "" then
            path = "./"
        end
        local pos = string.format("%3d:%2d", mark[1], mark[2])
        local line = name .. " " .. pos .. " " .. path
        state.prev_lines[drawline] = line

        api.nvim_buf_set_lines(state.render_buf, drawline, drawline, false, { line })

        local hlgroup
        if vim.startswith(mark[4], "oil://") then
            hlgroup = "OilDir"
        else
            hlgroup = require("config.utils").highlight_fname(path)
        end
        api.nvim_buf_add_highlight(state.render_buf, state.ns, hlgroup, drawline, 3 + #pos, -1)
        api.nvim_buf_add_highlight(state.render_buf, state.ns, "MarkGlobal", drawline, 0, 1)

        api.nvim_buf_add_highlight(state.render_buf, state.ns, "MarkPosition", drawline, 2, 2 + #pos)

        drawline = drawline + 1
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

                local path = vim.fn.expand(file)
                local st = vim.uv.fs_stat(path)
                if st and st.type == "directory" then
                    path = "oil://" .. path
                end
                local buf = vim.fn.bufadd(path)
                local ok, res = pcall(api.nvim_buf_set_mark, buf, mark, row, column, {})
                if not ok then
                    state.found_old_marks[mark] = false
                    vim.notify("markeditor: Failed to set mark " .. mark .. ": " .. res)
                end
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
    if popup_win then
        vim.fn.win_gotoid(popup_win)
        return
    end

    local curbuf = api.nvim_get_current_buf()
    local buf = api.nvim_create_buf(false, true)

    local win_width = vim.o.columns
    local win_height = vim.o.lines

    local width = win_width >= 60 and 58 or win_width - 2
    local height = win_height >= 10 and 8 or win_height - 2

    local target_col = math.floor((win_width - width) / 2)
    local target_row = math.floor((win_height - height) / 2)
    local win = api.nvim_open_win(buf, true, {
        border = "rounded",
        relative = "editor",
        title = "Marks",
        title_pos = "center",
        width = width,
        height = height,
        row = target_row,
        col = target_col,
    })
    popup_win = win

    vim.bo[buf].buftype = "acwrite"
    vim.bo[buf].filetype = "marked"
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
        vim.cmd((precmd and precmd .. "|" or "") .. "normal! `" .. mark)
    end

    local map = require("config.utils").local_mapper(buf)
    map("n", "<cr>", function() open_mark() end)
    map("n", "v", function() open_mark("vsplit") end)
    map("n", "s", function() open_mark("split") end)
    map("n", "t", function() open_mark("tabnew") end)
    map("n", "'", function()
        local mark = vim.fn.getchar()
        vim.cmd.quit()
        M.jump_first_set_mark(mark)
    end)

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
            popup_win = nil
        end
    })

    render_buf(state)
end

local function find_fist_avail_mark(buf, letters)
    for _, mark in pairs(letters) do
        local res = api.nvim_buf_get_mark(buf, mark)
        if res[1] == 0 then
            return mark
        end
    end
    return nil
end

function M.set_first_avail_gmark()
    local mark = find_fist_avail_mark(0, uppercase)
    if mark then
        vim.cmd("normal! m" .. mark)
        print(mark)
    else
        vim.notify("All marks used", vim.log.levels.ERROR)
    end
end

function M.set_first_avail_lmark()
    local mark = find_fist_avail_mark(0, lowercase)
    if mark then
        vim.cmd("normal! m" .. mark)
        print(mark)
    else
        vim.notify("All marks used", vim.log.levels.ERROR)
    end
end

function M.jump_first_set_mark(code)
    if not code then
        code = vim.fn.getchar()
    end
    local char = string.char(code)

    if char:upper() == char then
        vim.cmd("normal! `" .. char)
        return
    end

    if code < 97 or code > 122 then
        vim.notify("Invalid mark: " .. char, vim.log.levels.ERROR)
        return
    end

    local curbuf = api.nvim_get_current_buf()
    local lmark = api.nvim_buf_get_mark(curbuf, char)
    if lmark[1] ~= 0 then
        vim.cmd("normal! `" .. char)
        return
    end

    for _, buf in pairs(api.nvim_list_bufs()) do
        if buf == curbuf then
            goto continue
        end
        local mark = api.nvim_buf_get_mark(buf, char)
        if mark[1] ~= 0 then
            local win = vim.fn.bufwinid(buf)
            if win == -1 then
                api.nvim_set_current_buf(buf)
            else
                api.nvim_set_current_win(win)
            end

            vim.cmd("normal! `" .. char)
            return
        end

        ::continue::
    end
end

return M
