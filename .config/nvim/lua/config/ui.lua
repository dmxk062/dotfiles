local M = {}
local fn = vim.fn
local api = vim.api
local ns = api.nvim_create_namespace("config.ui.ui")
local hlns = api.nvim_create_namespace("config.ui.hl")
local utils = require("config.utils")

-- vim.ui.input {{{
local cur_completion
M.nvim_input_omnifunc = function(start, base)
    local compl = cur_completion
    if not compl then
        return start == 1 and 0 or {}
    end
    if start == 1 then
        return 0
    end

    local parts = vim.split(compl, ",", { plain = true })
    local ret
    if parts[1] == "custom" or parts[1] == "customlist" then
        local func = parts[2]
        if vim.startswith(func, "v:lua.") then
            local lua_to_load = ("return %s(...)"):format(func:sub(7))
            local luafunc, err = loadstring(lua_to_load)
            if not luafunc then
                vim.notify(("Failed to load lua omnifunc '%s': %s"):format(lua_to_load, err), vim.log.levels.ERROR)
                return {}
            end

            ret = luafunc(base, base, fn.strlen(base))
        else
            ret = fn[func](base, base, fn.strlen(base))
        end
        if parts[1] == "custom" then
            ret = vim.split(ret, "\n", { plain = true })
        end

        return ret
    end

    local ok, result = pcall(fn.getcompletion, base, compl)
    if ok then
        return result
    else
        return {}
    end
end

local last_was_insert

--[[ vim.ui.input implementation
WARNING: This is *not* 100% what neovim says it should be, instead I add my own private features,
starting with an underscore:
  _ts_lang: highlight the buffer using that treesitter language
]] --
---@param opts {prompt: string?, default: string?, completion: string?, highlight: function, _ts_lang: string?}
---@param callback fun(string?)
M.nvim_input = function(opts, callback)
    last_was_insert = api.nvim_get_mode().mode:find("[it]") and true or false

    local buf = api.nvim_create_buf(false, true)
    local title = opts.prompt and opts.prompt:gsub("%s*:%s*", "") or "Input"

    if opts.default then
        api.nvim_buf_set_lines(buf, 0, 0, false, { opts.default })
    end

    api.nvim_buf_set_name(buf, "[Input]")
    local bo = vim.bo[buf]
    bo.filetype = "Input"
    bo.swapfile = false
    bo.bufhidden = "wipe"
    bo.omnifunc = "v:lua.require'config.ui'.nvim_input_omnifunc"
    cur_completion = opts.completion

    local lines = vim.o.lines
    local columns = vim.o.columns
    local win = api.nvim_open_win(buf, true, {
        title = title,
        relative = "editor",
        anchor = "SW",
        style = "minimal",
        row = lines - 2,
        col = 0,
        width = math.max(40, math.min(16, math.floor(columns * 0.3))),
        height = 1,
    })

    -- HACK: add my own extension
    if opts._ts_lang then
        require("nvim-treesitter.highlight").attach(buf, opts._ts_lang)
    end

    local augroup
    local clean = function()
        api.nvim_del_augroup_by_id(augroup)
        pcall(api.nvim_win_close, win, true)
        pcall(api.nvim_buf_delete, win, { force = true })
        if last_was_insert then
            vim.cmd.startinsert()
        else
            vim.cmd.stopinsert()
        end
    end
    local cancel = function()
        callback(nil)
        clean()
    end
    local confirm = function()
        local text = api.nvim_buf_get_lines(buf, 0, -1, false)[1]
        callback(text)
        clean()
    end

    augroup = utils.autogroup("config.ui.input." .. buf, {
        BufLeave                            = cancel,
        [{ "TextChanged", "TextChangedI" }] = function()
            local txt = api.nvim_buf_get_lines(buf, 0, 1, true)[1]
            local hls = {}

            if type(opts.highlight) == "function" then
                hls = opts.highlight(txt)
            elseif opts.highlight then
                hls = fn[opts.highlight](txt)
            end

            api.nvim_buf_clear_namespace(buf, ns, 0, -1)
            for _, hl in ipairs(hls) do
                api.nvim_buf_set_extmark(buf, ns, 0, hl[1], {
                    end_line = 0,
                    end_col = hl[2],
                    hl_group = hl[3],
                })
            end
        end
    }, { buf = buf })
    local map = function(mode, lhs, rhs, map_opts)
        map_opts = map_opts or {}
        map_opts.buffer = buf
        vim.keymap.set(mode, lhs, rhs, map_opts)
    end

    map({ "i", "n" }, "<cr>", confirm)
    map({ "n" }, "<esc>", confirm)
    map({ "i", "s" }, "<Tab>", "<C-n>", { remap = true })

    if not opts.default then
        vim.cmd.startinsert()
    end
end
-- }}}

--[[ Minibuffer {{{
Get lua code input from the user
Using :w
will return the buffer content's result if evaluated
]]
---@param opts {template: string, callback: fun(res: any), layout: config.win.opts?, type: type}
M.evaluate_lua = function(opts)
    local buf = api.nvim_create_buf(false, true)
    local bo = vim.bo[buf]
    bo.filetype = "lua"
    bo.swapfile = false
    bo.buftype = "acwrite"
    bo.bufhidden = "delete"

    vim.b[buf].special_buftype = "luaeval"
    api.nvim_buf_set_name(buf, "eval")

    local lua_ls = vim.lsp.get_clients { name = "luals" }[1]
    local client_id
    if not lua_ls then
        local config = vim.deepcopy(vim.lsp.config.luals)
        config.root_dir = fn.stdpath("config")
        client_id = vim.lsp.start(config, { attach = false })
    else
        client_id = lua_ls.id
    end

    if client_id then
        vim.lsp.buf_attach_client(buf, client_id)
    end

    local win = utils.win_show_buf(buf, opts.layout or {})
    api.nvim_win_call(win, function()
        vim.snippet.expand(opts.template)
    end)

    local try_evaluate = function()
        local text = table.concat(api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
        local chunk, err = loadstring(text)
        if err or not chunk then
            vim.notify(err or "Failed to load lua", vim.log.levels.ERROR)
            return
        end

        local ok, result = pcall(chunk)
        if not ok then
            vim.notify(result, vim.log.levels.ERROR)
            return
        end

        local return_type = type(result)
        if return_type ~= opts.type then
            vim.notify(("Expected to get '%s', not '%s'"):format(opts.type, return_type), vim.log.levels.ERROR)
            return
        end

        api.nvim_win_close(win, true)
        api.nvim_buf_delete(buf, { force = true })
        opts.callback(result)
    end

    utils.autogroup("config.minibuffer", {
        BufWriteCmd = function()
            try_evaluate()
        end
    }, { buf = buf })
end
-- }}}

return M
