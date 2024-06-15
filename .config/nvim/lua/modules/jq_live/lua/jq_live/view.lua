local M = {}
local J = require("jq_live.jq")

---@param result string[]
function M.show_query_output(result, opts)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].ft = "json"

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
    vim.bo[buf].modifiable = false

    local width = math.ceil(vim.o.columns * opts.width)
    local height = math.ceil(vim.o.lines * opts.height)

    local col = vim.o.columns / 2 - width / 2
    local row = vim.o.lines / 2 - height / 2

    vim.keymap.set("n", "<ESC>", "<cmd>q<cr>", { buffer = buf })
    local winopts = {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
    }
    vim.api.nvim_open_win(buf, true, vim.tbl_extend('force', winopts, opts.winopts))
end

---@param buf integer
---@param line1 integer
---@param line2 integer
function M.live_query(buf, line1, line2, opts)
    local entry_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[entry_buf].ft = "jq"
    vim.bo[entry_buf].buftype = "acwrite"
    vim.bo[entry_buf].swapfile = false
    vim.bo[entry_buf].modifiable = true

    local output_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[output_buf].modifiable = false
    vim.bo[output_buf].ft = "jsonc"

    local win_height = math.ceil(vim.o.lines * opts.height)
    local win_height_pos = math.ceil((vim.o.lines / 2) - (win_height / 2))

    local entry_win = vim.api.nvim_open_win(entry_buf, true, {
        width    = math.ceil(vim.o.columns * opts.ratio) - 3,
        height   = win_height,
        row      = win_height_pos,
        col      = 0,
        title    = opts.input_title,
        relative = "editor",
        border   = opts.winopts.border,
        style    = opts.winopts.style,
    })

    local output_win = vim.api.nvim_open_win(output_buf, false, {
        width    = math.ceil(vim.o.columns * (1 - opts.ratio)) - 3,
        height   = win_height,
        row      = win_height_pos,
        col      = math.ceil(vim.o.columns / 2),
        title    = opts.output_title,
        relative = "editor",
        border   = opts.winopts.border,
        style    = opts.winopts.style,
    })


    vim.api.nvim_create_autocmd("WinClosed", {
        buffer = entry_buf,
        once = true,
        callback = function()
            pcall(function() 
                vim.api.nvim_win_close(entry_win, true)
                vim.api.nvim_win_close(output_win, true)
                vim.api.nvim_buf_delete(entry_buf, { force = true })
                vim.api.nvim_buf_delete(output_buf, { force = true })
            end)
        end
    })

    opts.callback(buf, entry_buf, output_buf)

    require("cmp").setup.buffer {
        sources = {
            {
                name = "buffer", option = {
                get_bufnrs = function()
                    return { buf, entry_buf }
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
            local filtered, err = J.jq_query_lines(buf, line1, line2, { filter })
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

return M
