local M = {}
local api = vim.api
local utils = require("config.utils")

---@class config.luabuffer.opts
---@field type "value"|"function"?
---@field multiline boolean?
---@field once boolean?
---@field win config.win.opts?
---@field template string?
---@field name string?

---@param opts config.luabuffer.opts
---@param callback fun(buf: integer, ok: boolean, chunk: function|string)
M.get_lua_expr = function(opts, callback)
    local buf = api.nvim_create_buf(false, true)
    local bo = vim.bo[buf]
    vim.b[buf].special_buftype = "luaeval"
    api.nvim_buf_set_name(buf, opts.name or "Eval")


    bo.ft = "lua"

    local win = utils.win_show_buf(buf, opts.win)
    local on_confirm = function()
        local text = api.nvim_buf_get_lines(buf, 0, -1, false)
        local chunk, err = load(table.concat(text, "\n"), "[luabuf]")

        if opts.once then
            pcall(api.nvim_win_hide, win)
        end
        callback(buf, chunk ~= nil, chunk or err or "")
    end

    if opts.template then
        api.nvim_win_call(win, function()
            vim.snippet.expand(opts.template)
        end)
    end


    local augroup
    augroup = utils.autogroup("config.luabuffer." .. buf, {
        BufLeave = function()
            api.nvim_buf_delete(buf, { force = true })
            api.nvim_del_augroup_by_id(augroup)
        end,
    }, { buf = buf })

    -- set mappings
    local map = utils.local_mapper(buf, {})
    map("n", "<cr>", on_confirm)
    if opts.template then
        map({"n", "s", "i"}, "<up>", function() vim.snippet.jump(-1) end)
        map({"n", "s", "i"}, "<down>", function() vim.snippet.jump(1) end)
    end

end

return M
