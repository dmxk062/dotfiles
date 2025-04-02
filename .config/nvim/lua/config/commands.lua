local api = vim.api
local terminal = require("config.terminal")

-- Zoxide {{{
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
vim.api.nvim_create_user_command("Zed", function(args)
    local name = args.fargs[1]
    local dir = get_zoxide_result(name)
    if not dir or dir == "" then
        vim.notify("Zoxide: could not find " .. name, vim.log.levels.ERROR)
        return
    end

    local mods = args.smods
    local cmd = mods.vertical and "vsplit" or (mods.horizontal and "split" or "edit")
    vim.cmd[cmd](dir)
end, {
    nargs = 1,
    complete = complete_zoxide,
    desc = "Use zoxide to open dir in an oil buffer"
})

local zcd_func = function(args)
    local name = args.fargs[1]
    local dir = get_zoxide_result(name)
    if not dir or dir == "" then
        vim.notify("Zoxide: could not find " .. name, vim.log.levels.ERROR)
        return
    end

    vim.cmd.lcd(dir)
end
local zcd_args = {
    nargs = 1,
    complete = complete_zoxide,
    desc = ":lcd using zoxide"
}
vim.api.nvim_create_user_command("Z", zcd_func, zcd_args)
vim.api.nvim_create_user_command("Zcd", zcd_func, zcd_args)
-- }}}

-- Automatic Split {{{
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
-- }}}

-- Shell Utils {{{

---Set qflist/loclist (with !bang) to result of command
api.nvim_create_user_command("Csh", function(args)
    local command = args.fargs
    local exit = vim.system(command, {
        text = true
    }):wait()

    if exit.code ~= 0 then
        vim.notify(("%s: %s exited with code %d:\n%s")
            :format(args.name, vim.inspect(command), exit.code, exit.stderr),
            vim.log.levels.ERROR)
        return
    end

    -- errorfmt is too complex for this, a simple list of names works
    local items = vim.tbl_map(function(line)
        local path, rest = line:match("([^:]+):?(.*)")
        local row, col, ctx
        if rest then
            row, col, ctx = rest:match("(%d+):(%d+):(.*)")
        end
        return { filename = path, row = row, col = col, text = ctx or path }
    end, vim.split(exit.stdout, "\n"))

    if args.bang then
        vim.fn.setloclist(0, items)
    else
        vim.fn.setqflist(items)
    end
end, { complete = "shellcmd", nargs = "+", bang = true })

---Run a single command in a floating window
api.nvim_create_user_command("Ft", function(args)
    terminal.open_term {
        position = "float",
        cmd = #args.fargs > 0 and args.fargs or nil,
        autoclose = args.bang,
    }
end, { complete = "shellcmd", nargs = "*", bang = true })
-- }}}

-- Spell {{{
api.nvim_create_user_command("Spell", function(args)
    return require("config.spell").spell_cmd(args)
end, {
    complete = function(...)
        return require("config.spell").spell_cmd_complete(...)
    end,
    nargs = "*",
})
-- }}}
