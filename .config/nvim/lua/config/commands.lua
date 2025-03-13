local fn = vim.fn
local api = vim.api

---@class vim.user_command_args
---@field name string
---@field args string
---@field fargs string[]
---@field nargs string
---@field bang boolean
---@field line1 number
---@field line2 number
---@field range 0|1|2
---@field count number
---@field reg string
---@field mods string
---@field smods table

local function get_zoxide_result(path)
    local expanded = path:gsub("~", vim.env.HOME)
    local cmd = { "zoxide", "query", expanded }
    local res = vim.system(cmd, {}):wait().stdout
    local dir = (res or ""):gsub("%s*$", "")
    if dir == "" or not dir then
        if vim.uv.fs_stat(path) then
            return path
        end
    end

    return dir
end

local function complete_zoxide(l, line, cpos)
    return vim.tbl_map(function(path)
        return path:gsub(vim.env["HOME"], "~")
    end, vim.split(vim.system({ "zoxide", "query", "-l", l }):wait().stdout, "\n"))
end

-- Use zoxide to edit a directory using oil
vim.api.nvim_create_user_command("Z", function(args)
    local name = args.fargs[1]
    local dir = get_zoxide_result(name)
    if not dir or dir == "" then
        vim.notify("Zoxide: could not find " .. name, vim.log.levels.ERROR)
        return
    end

    vim.cmd.edit(dir)
end, {
    nargs = 1,
    complete = complete_zoxide,
    desc = "Use zoxide to open dir in an oil buffer"
})

---@param args vim.user_command_args
local function smart_split(args)
    local height = vim.api.nvim_win_get_height(0)
    local width = vim.api.nvim_win_get_width(0)

    local cmd
    if height * 2.6 > width then
        cmd = "split"
    else
        cmd = "vsplit"
    end

    local split_args = {
        range = {
            math.floor((cmd == "split" and height or width) / 2)
        }
    }

    if args.args ~= "" then
        split_args[1] = args.args
    end

    vim.cmd[cmd](split_args)
end

local split_cmd_opts = {
    complete = "file",
    nargs = "?",
    count = 0,
}

vim.api.nvim_create_user_command("Sp", smart_split, split_cmd_opts)
vim.api.nvim_create_user_command("Split", smart_split, split_cmd_opts)

vim.api.nvim_create_user_command("Xxd", function(opts)
    if vim.b[0].xxd_last_pos then
        return
    end

    local buf = api.nvim_get_current_buf()
    local xxd_cmd = function(args)
        vim.cmd { cmd = "!", args = { "xxd " .. (args or "") },
            range = { 0, api.nvim_buf_line_count(buf) },
            mods = { silent = true }
        }
    end

    xxd_cmd()

    vim.bo[buf].filetype = "xxd"
    vim.b[buf].xxd_last_pos = {0,0}

    local augroup = api.nvim_create_augroup("xxd:" .. buf, { clear = true })

    api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = buf,
        callback = function()
            vim.b[buf].xxd_last_pos = api.nvim_win_get_cursor(0)
            xxd_cmd("-r")
        end
    })
    api.nvim_create_autocmd("BufWritePost", {
        group = augroup,
        buffer = buf,
        callback = function()
            xxd_cmd()
            api.nvim_win_set_cursor(0, vim.b[buf].xxd_last_pos)
            vim.bo[buf].modified = false
        end
    })

    api.nvim_create_autocmd("BufDelete", {
        group = augroup,
        buffer = buf,
        callback = function()
            api.nvim_del_augroup_by_id(augroup)
        end
    })
end, {})
