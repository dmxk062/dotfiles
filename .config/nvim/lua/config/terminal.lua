local M = {}
local api = vim.api
local utils = require("config.utils")
local fn = vim.fn

M.last_term = 0

---@alias TermUrl [integer, integer, integer, integer, string]
---@type TermUrl[]
M.urls_for_buffers = {}
local last_osc8_start
local last_osc8_path

local hostname = fn.hostname()

-- General autocommands {{{
-- remove the builtin handler
utils.del_autocommand("nvim.terminal", "TermClose")

---@param buf integer
---@param fun fun(res: {pos: [integer, integer], url: TermUrl})
local function operate_on_urls(buf, fun)
    local info = fn.getwininfo(api.nvim_get_current_win())[1]
    local first = info.topline
    local last = info.botline

    local targets = {}
    for _, url in ipairs(M.urls_for_buffers[buf]) do
        if url[1] >= first then
            table.insert(targets, {
                pos = { url[1], url[2] + 1 },
                url = url
            })
        elseif url[1] > last then
            break
        end
    end
    require("leap.main").leap {
        targets = targets,
        action = fun
    }
end

utils.autogroup("config.terminal_mode", {
    -- saner options
    TermOpen = function(ev)
        vim.wo[0][0].number = false
        vim.wo[0][0].relativenumber = false
        vim.wo[0][0].statuscolumn = ""
        vim.wo[0][0].signcolumn = "no"
        -- immediately hand over control
        vim.cmd.startinsert()

        M.urls_for_buffers[ev.buf] = {}

        local map = utils.local_mapper(ev.buf)

        local split_path = function()
            operate_on_urls(ev.buf, function(res)
                vim.cmd.Split(res.url[5])
            end)
        end

        map("n", "<localleader>f", split_path)
        map("t", "<M-p>", split_path)
        map("t", "<M-i>", function()
            operate_on_urls(ev.buf, function(res)
                vim.api.nvim_paste(fn.shellescape(res.url[5]), false, -1)
            end)
        end)
    end,

    -- automatically close interactive term buffers
    TermClose = {
        nested = true, -- trigger BufDelete
        callback = function(ev)
            if vim.v.event.status ~= 0 then
                return
            end

            if vim.b[ev.buf].term_autoclose == true then
                api.nvim_win_close(0, true)
                api.nvim_buf_delete(ev.buf, { force = true })
            end

            M.urls_for_buffers[ev.buf] = nil
        end
    },

    -- automatically enter insert
    [{ "BufWinEnter", "WinEnter" }] = function(ev)
        -- make sure that remote leap operations are not affected
        if vim.bo[ev.buf].buftype == "terminal" then
            vim.cmd.startinsert()
            M.last_term = ev.buf
        end
    end,

    -- allow doing things with osc-8 file urls in the buffer
    TermRequest = function(ev)
        ---@type string
        local escape = ev.data.sequence
        ---@type [integer, integer]
        local cursor = ev.data.cursor
        if escape:sub(1, 3) ~= "\x1b]8" then
            return
        end

        if last_osc8_start then
            table.insert(M.urls_for_buffers[ev.buf], {
                last_osc8_start[1],
                last_osc8_start[2],
                cursor[1],
                cursor[2],
                last_osc8_path,
            })
            last_osc8_start = nil
            return
        end

        local uri = escape:gsub("^\x1b]8;.-;", "")
        if vim.startswith(uri, "file://") then
            local host = uri:match("^file://(.-)/")
            if host and host ~= "" then
                if host == hostname then
                    last_osc8_path = vim.uri_to_fname(uri:gsub("^file://.-/", "file:///"))
                end
            else
                last_osc8_path = vim.uri_to_fname(uri)
            end
            last_osc8_start = cursor
        end
    end
})
-- }}}

local function get_cmd_and_cwd(bufname, opts)
    local cmd = {}
    local cwd = ""
    local final_cmd = false

    if vim.startswith(bufname, "oil-ssh://") then
        final_cmd = true
        local addr, remote_path = bufname:match("//(.-)(/.*)")
        vim.list_extend(cmd, { "ssh", "-t", addr, "--", "cd", remote_path:sub(2, -1), ";", "exec", "${SHELL:-/bin/sh}" })
    elseif vim.startswith(bufname, "oil://") then
        cwd = require("oil").get_current_dir()
    elseif opts.cwd then
        cwd = opts.cwd
    else
        cwd = fn.fnamemodify(bufname, ":p:h")
        if not vim.uv.fs_stat(cwd) then
            cwd = fn.getcwd()
        end
    end

    if not final_cmd then
        if opts.cmd then
            vim.list_extend(cmd, opts.cmd)
        else
            vim.list_extend(cmd, { vim.o.shell })
        end
    end

    return cmd, cwd
end

---@param opts {position: config.win.position, cmd: string[]|nil, cwd: string|nil, title: string|nil, size: [number, number], autoclose: boolean?}
function M.open_term(opts)
    local bname = api.nvim_buf_get_name(0)
    local cmd, cwd = get_cmd_and_cwd(bname, opts)

    local b = api.nvim_create_buf(true, false)
    vim.b[b].term_autoclose = opts.autoclose == nil and true or opts.autoclose

    utils.win_show_buf(b, { position = opts.position, size = opts.size })

    fn.jobstart(cmd, {
        cwd = cwd,
        term = true,
    })

    M.last_term = b

    if opts.title then
        vim.b[0].term_title = opts.title
    end
end

return M
