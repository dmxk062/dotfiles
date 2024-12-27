local function get_zoxide_result(path)
    local cmd = { "zoxide", "query", path }
    local res = vim.system(cmd, {}):wait().stdout
    local dir = (res or ""):gsub("%s*$", "")
    if dir == "" or not dir then
        if vim.uv.fs_stat(path) then
            return path
        end
    end

    return dir
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
    complete = "dir",
    desc = "Use zoxide to open dir in an oil buffer"
})
