--[[ Information {{{
Basically markdown files with eval-able codeblocks
TODO: lua
TODO: shell
TODO: python
TODO: math (qalc)
}}} ]]

local api = vim.api
local fn = vim.fn
local utils = require("config.utils")
local M = {}

---@class config.scratch.buf
---@field buf integer
---@field win integer?
---@field type string
---@field augroup integer

---@type table<string, config.scratch.buf>
local state = {}


-- Evaluators {{{
local ns = api.nvim_create_namespace("config.scratch")

---@param scratch config.scratch.buf
local get_last_print_num = function(scratch)
    local num
    for level = 2, 20 do
        local info = debug.getinfo(level, "Sln")
        if info and info.source == "@scratch" then
            num = info.currentline
            break
        end
    end


    local line = api.nvim_buf_get_lines(scratch.buf, num - 1, num, false)[1]
    local start = line:find("%a")
    local node = vim.treesitter.get_node { bufnr = scratch.buf, pos = { num - 1, start } }
    if not node then
        return num
    end
    local args = node:next_named_sibling()
    if not args then
        return num
    end
    local _, _, erow, _ = vim.treesitter.get_node_range(args)
    return erow + 1
end

local get_last_err_num = function(msg)
    local line = msg and msg:match("^scratch:(%d+):")
    if line then
        return tonumber(line)
    end

    for level = 2, 20 do
        local info = debug.getinfo(level, "Sln")
        if info and info.source == "@scratch" then
            return info.currentline
        end
    end
end

---@param scratch config.scratch.buf
---@param msg string
local on_lua_err = function(scratch, msg)
    local line = get_last_err_num(msg)
    vim.diagnostic.set(ns, scratch.buf, { {
        lnum = line,
        col = 0,
        message = msg
    } })
end

---@param scratch config.scratch.buf
local lua_attach_to_eval_buffer = function(scratch)
    local print_handler = function(...)
        local lnum = get_last_print_num(scratch)

        local hierarchy = table.concat(vim.tbl_map(function(v)
            return vim.inspect(v)
        end, { ... }))

        local lines = {}
        for _, line in ipairs(vim.split(hierarchy, "\n")) do
            table.insert(lines, { { line, "Comment" } })
        end

        lines[1][1][1] = "=> " .. lines[1][1][1]

        api.nvim_buf_set_extmark(scratch.buf, ns, lnum - 1, 0, {
            end_line = lnum,
            virt_lines_overflow = "scroll",
            virt_lines = lines
        })
    end

    local function update(mapping)
        api.nvim_buf_clear_namespace(scratch.buf, ns, 0, -1)
        vim.diagnostic.reset(ns, scratch.buf)
        local lines = api.nvim_buf_get_lines(scratch.buf, 0, -1, false)

        local autoeval = false
        for i = 1, math.max(#lines or 9) do
            if lines[i]:match("%[x]%s*autoeval") then
                autoeval = true
                break
            end
        end
        if not autoeval then
            return
        end

        local text = table.concat(lines, "\n")
        local chunk, err = load(text, "@scratch")
        if not chunk then
            on_lua_err(scratch, err)
            return
        end
        local env = { print = print_handler }

        package.seeall(env)
        setfenv(chunk, env)
        xpcall(chunk, function(e)
            on_lua_err(scratch, e)
        end)
    end

    api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
        group = scratch.augroup,
        buffer = scratch.buf,
        callback = function()
            update(false)
        end
    })
    vim.keymap.set("n", "<cr>", function() update(true) end, { buffer = scratch.buf })
    update(false)
end

---@param scratch config.scratch.buf
local markdown_attach_to_buffer = function(scratch)
end
-- }}}

local scratchpath = fn.expand("~/ws/scratch")

local filetypes = {
    lua = {
        ext = ".lua",
        template = {
            "---@diagnostic disable-next-line: unused-local",
            "local api, fn, env, map, filter, extend = vim.api, vim.fn, vim.env, vim.tbl_map, vim.tbl_filter, vim.tbl_extend",
            "--[[ INFO: Lua Scratch-Eval Buffer",
            "[x] autoeval",
            "--]]",
            "",
            "",
        },
        attach = lua_attach_to_eval_buffer
    },
    markdown = {
        ext = ".md",
        template = {
            "# Scratch Buffer",
            ""
        },
        attach = markdown_attach_to_buffer
    },
}

---@param opts {name: string?, path: string?, type: "lua"|"markdown", win: config.win.opts?}
M.show_scratch_buffer = function(opts)
    local typeconfig = filetypes[opts.type] or {}
    local path = opts.path or (scratchpath .. "/" .. opts.name .. (typeconfig.ext or ""))

    local open = state[path]
    if open then
        if open.win then
            api.nvim_set_current_win(open.win)
        else
            utils.win_show_buf(open.buf, opts.win)
        end

        return
    end

    local buf = fn.bufadd(path)
    fn.bufload(buf)

    local bo = vim.bo[buf]
    bo.buflisted = true
    bo.swapfile = false

    vim.b[buf].special_buftype = "scratch"

    local win = utils.win_show_buf(buf, opts.win)
    local template = typeconfig.template or {}
    if not vim.uv.fs_stat(path) then
        api.nvim_buf_set_lines(buf, 0, -1, false, template)
        bo.modified = false
    end
    api.nvim_win_set_cursor(win, { #template, 0 })


    local instance = {
        buf = buf,
        win = win,
        type = opts.type
    }
    state[path] = instance

    local augroup
    augroup = utils.autogroup("config.scratch." .. buf, {
        BufHidden = function()
            instance.win = nil
        end,
        BufDelete = function()
            state[path] = nil
            api.nvim_del_augroup_by_id(augroup)
        end
    }, { buf = buf })
    instance.augroup = augroup

    if typeconfig.attach then
        typeconfig.attach(instance)
    end
end

return M
