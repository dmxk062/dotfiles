local M = {}
local api = vim.api
local utils = require("config.utils")
local fn = vim.fn

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

---@param opts {position: config.win.position, cmd: string[]|nil, cwd: string|nil, title: string|nil, size: [number, number]}
function M.open_term(opts)
    local bname = api.nvim_buf_get_name(0)
    local cmd, cwd = get_cmd_and_cwd(bname, opts)

    local b = api.nvim_create_buf(true, false)

    opts.size = opts.size or {}
    utils.win_show_buf(b, { position = opts.position, size = opts.size})

    fn.termopen(cmd, {
        cwd = cwd,
    })

    if opts.title then
        vim.b[0].term_title = opts.title
    end
end

return M
