local function get_zoxide_result(path)
    local expanded = path:gsub("~", vim.env.HOME)
    local cmd = { "zoxide", "query", expanded}
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
