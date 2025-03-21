local M = {}
local api = vim.api
local utils = require("config.utils")
local fn = vim.fn

M.last_term = 0

-- General autocommands {{{
local nvim_builtin_termclose = api.nvim_get_autocmds { group = "nvim_terminal", event = "TermClose" }
api.nvim_del_autocmd(nvim_builtin_termclose[1].id)

utils.autogroup("config.terminal_mode", {
    -- saner options
    TermOpen = function()
        vim.wo[0][0].number = false
        vim.wo[0][0].relativenumber = false
        vim.wo[0][0].statuscolumn = ""
        vim.wo[0][0].signcolumn = "no"
        -- immediately hand over control
        vim.cmd.startinsert()
    end,

    -- automatically close interactive term buffers
    TermClose = {
        nested = true, -- trigger BufDelete
        callback = function(ev)
            if vim.v.event.status ~= 0 then
                return
            end

            if vim.b[ev.buf].term_autoclose then
                api.nvim_buf_delete(ev.buf, { force = true })
            end
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
    vim.b[b].term_autoclose = opts.autoclose or true

    utils.win_show_buf(b, { position = opts.position, size = opts.size })

    local job = fn.termopen(cmd, {
        cwd = cwd,
    })

    M.jobs_for_buffers[b] = job
    M.last_term = b

    api.nvim_create_autocmd("BufDelete", {
        buffer = b,
        once = true,
        callback = function()
            M.jobs_for_buffers[b] = nil
        end
    })

    if opts.title then
        vim.b[0].term_title = opts.title
    end
end

M.jobs_for_buffers = {}

---@param buffer integer
---@param text string[]
function M.enter_text(buffer, text)
    local jobid = M.jobs_for_buffers[buffer]
    if not jobid then
        vim.notify("No job in that buffer", vim.log.levels.ERROR)
        return
    end

    fn.chansend(jobid, text)
end
return M
