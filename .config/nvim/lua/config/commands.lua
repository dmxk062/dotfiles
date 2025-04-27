local api = vim.api
local terminal = require("config.terminal")
local command = api.nvim_create_user_command

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
command("Zed", function(args)
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
    desc = "Use zoxide to open DIR in an oil buffer"
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
command("Z", zcd_func, zcd_args)
command("Zcd", zcd_func, zcd_args)
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
    desc = "Split based on spiral layout",
    complete = "file",
    nargs = "?",
    count = 0,
}

command("Sp", smart_split, split_cmd_opts)
command("Split", smart_split, split_cmd_opts)
-- }}}

-- Shell Utils {{{

---Set qflist/loclist (with !bang) to result of command
command("Csh", function(args)
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
end, {
    desc = "Populate qflist (or loclist with !) with shell command",
    complete = "shellcmd",
    nargs = "+",
    bang = true
})

---Run a single command in a floating window
command("Ft", function(args)
    terminal.open_term {
        position = "float",
        cmd = #args.fargs > 0 and args.fargs or nil,
        autoclose = args.bang,
    }
end, {
    desc = "Run CMD in floating terminal",
    complete = "shellcmd",
    nargs = "*",
    bang = true
})
-- }}}

-- Spell {{{
command("Spell", function(args)
    return require("config.spell").spell_cmd(args)
end, {
    desc = "Set spelling",
    complete = function(...)
        return require("config.spell").spell_cmd_complete(...)
    end,
    nargs = "*",
})
-- }}}

-- LSP {{{
local lsp_complete_clients = function()
    return vim.tbl_map(function(client)
        return client.name
    end, vim.lsp.get_clients { bufnr = 0 })
end

local iter_clients = function(buf, name)
    return ipairs(vim.lsp.get_clients { bufnr = buf, name = name })
end

command("LspStop", function(args)
    local buf = api.nvim_get_current_buf()
    for _, client in iter_clients(buf, args.fargs[1]) do
        client:stop()
    end
end, {
    desc = "Stop LSP servers",
    nargs = "*",
    complete = lsp_complete_clients,
})

command("LspRestart", function(args)
    local buf = api.nvim_get_current_buf()
    for _, client in iter_clients(buf, args.fargs[1]) do
        local bufs = vim.deepcopy(client.attached_buffers)
        client:stop()
        vim.wait(20000, function()
            return vim.lsp.get_client_by_id(client.id) == nil
        end)

        local new_id = vim.lsp.start(client.config)
        if new_id then
            for b in pairs(bufs) do
                vim.lsp.buf_attach_client(b, new_id)
            end
        end
    end
end, {
    desc = "Restart LSP servers",
    nargs = "*",
    complete = lsp_complete_clients,
})

command("LspInfo", function(args)
    local buf = api.nvim_get_current_buf()
    for _, client in iter_clients(buf, args.fargs[1]) do
        local buffers = { table.concat(vim.tbl_keys(client.attached_buffers), ", "), "Number" }
        local cmd = { vim.inspect(client.config.cmd) }
        local rootdir = { client.root_dir or "nil", client.root_dir and "Directory" or "NonText" }

        local message = {
            { "\n" .. client.name, "Title" },
            { "\nBuffers: ",       "@property" }, buffers,
            { "\nCommand: ", "@property" }, cmd,
            { "\nRoot: ",    "@property" }, rootdir,
        }

        if client.server_info then
            vim.list_extend(message, {
                { "\nName: ",    "@property" }, { client.server_info.name, "Identifier" },
                { "\nVersion: ", "@property" }, { client.server_info.version, "SpecialChar" }
            })
        end

        api.nvim_echo(message, false, {})
    end
end, {
    desc = "Show LSP servers",
    nargs = "*",
    complete = lsp_complete_clients
})

-- }}}

command("Dash", function(args)
    require("config.dashboard").show()
end, { desc = "Open dashboard" })
