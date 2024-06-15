-- utilities for json files
-- mainly based on jq

local utils = require("utils")

local function jq_filter(lines, expr)
    local result = {}

    local cmd = vim.list_extend(
        { "jq", "--indent", tostring(vim.o.tabstop),
            "--argjson", "FILE", string.format([["%s"]], vim.fn.expand("%")),
        },
        expr or {})

    local res = vim.system(cmd, {
        stdin = lines,
    }):wait()

    if res.code > 0 then
        return nil, res.stderr
    end

    result = vim.split(res.stdout, "\n")

    return result
end

local function jq_query_lines(buf, start_line, end_line, query)
    local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
    return jq_filter(lines, query or {})
end

local function get_region(opts)
    if opts.range == 2 then
        return { opts.line1, opts.line2 }
    else
        return { 1, vim.api.nvim_buf_line_count(0) }
    end
end



vim.api.nvim_buf_create_user_command(0, "JqFilter", function(opts)
    local lines = get_region(opts)
    local filtered, err = jq_query_lines(0, lines[1], lines[2], opts.fargs)
    if err then
        vim.notify(err, vim.log.levels.ERROR)
    elseif filtered and #filtered > 0 then
        vim.api.nvim_buf_set_lines(0, lines[1] - 1, lines[2], false, filtered)
    end
end, {
    nargs = "*",
    range = 2,
})

local function show_query_output(result)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].ft = "json"

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
    vim.bo[buf].modifiable = false

    local width = math.ceil(vim.o.columns * 0.4)
    local height = math.ceil(vim.o.lines * 0.4)

    local col = vim.o.columns / 2 - width / 2
    local row = vim.o.lines / 2 - height / 2

    utils.lmap(buf, "n", "<ESC>", "<cmd>q<cr>")
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = "Query Result"
    })
end

local function open_win(buf, x, y, w, h, title, enter)
    local win = vim.api.nvim_open_win(buf, enter, {
        relative = "editor",
        width = w,
        height = h,
        row = y,
        col = x,
        style = "minimal",
        border = "rounded",
        title = title,
    })

    return win
end

local function live_query(buf, line1, line2)
    local entry_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[entry_buf].ft = "jq"
    vim.bo[entry_buf].buftype = "acwrite"
    vim.bo[entry_buf].swapfile = false
    vim.bo[entry_buf].modifiable = true

    local output_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[output_buf].modifiable = false
    vim.bo[output_buf].ft = "jsonc"

    local win_height = math.ceil(vim.o.lines / 1.5)
    local win_height_pos = math.ceil(vim.o.lines / 2 - win_height / 2)

    local entry_win = open_win(entry_buf, 0, win_height_pos, math.ceil(vim.o.columns * 0.33) - 2, win_height,
        "Query Input", true)

    local output_win = open_win(output_buf, vim.o.columns / 2, win_height_pos, math.ceil(vim.o.columns * 0.66) - 4,
        win_height, "Query Output", false)


    vim.api.nvim_create_autocmd("WinClosed", {
        buffer = entry_buf,
        once = true,
        callback = function()
            vim.api.nvim_win_close(entry_win, true)
            vim.api.nvim_win_close(output_win, true)

            vim.api.nvim_buf_delete(entry_buf, { force = true })
            vim.api.nvim_buf_delete(output_buf, { force = true })
        end
    })

    require("cmp").setup.buffer {
        sources = {
            {
                name = "buffer", option = {
                get_bufnrs = function()
                    return {buf, entry_buf}
                end
            }
            }
        }
    }
    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = entry_buf,
        callback = function()
            local lines = vim.api.nvim_buf_get_lines(entry_buf, 0, -1, false)
            local filter = table.concat(lines, "\n")
            if #filter == 0 then
                filter = "."
            end
            local filtered, err = jq_query_lines(buf, line1, line2, { filter })
            local text
            if err then
                text = vim.split(err or "", "\n")
                for i, str in ipairs(text) do
                    text[i] = "// " .. str
                end
            else
                text = filtered or { "" }
            end
            vim.bo[output_buf].modifiable = true
            vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, text)
            vim.bo[output_buf].modifiable = false
        end
    })
end

vim.api.nvim_buf_create_user_command(0, "JqQuery", function(opts)
    local lines = get_region(opts)
    if #opts.fargs ~= 0 then
        local filtered, err = jq_query_lines(0, lines[1], lines[2], opts.fargs)
        if err then
            vim.notify(err, vim.log.levels.ERROR)
            return
        end
        if filtered then
            show_query_output(filtered)
        end
    else
        live_query(vim.api.nvim_get_current_buf(), lines[1], lines[2])
    end
end, {
    nargs = "*",
    range = 2,
})
