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

-- Set qflist/loclist (with !bang) to result of command
-- Useful for e.g. ':Csh fd -e lua' or ':Csh git diff --name-only'
command("Csh", function(args)
    local cmd = args.fargs
    vim.system(cmd, {
        text = true
    }, vim.schedule_wrap(function(out)
        if out.code ~= 0 then
            vim.notify(("%s: %s exited with code %d:\n%s")
                :format(args.name, vim.inspect(cmd), out.code, out.stderr),
                vim.log.levels.ERROR)
            return
        end

        -- errorfmt is too complex for this, a simple list of names works
        local items = vim.tbl_map(function(line)
            local path, rest = line:match("([^:]+):?(.*)")
            if not path or path == "" then
                return
            end
            local row, col, ctx
            if rest then
                row, col, ctx = rest:match("(%d+):(%d+):(.*)")
                row = row and tonumber(row)
                col = col and tonumber(col)
            end
            return { filename = path, lnum = row or 1, col = col or 1, text = ctx or "" }
        end, vim.split(out.stdout, "\n"))

        if args.bang then
            vim.fn.setloclist(0, items)
            vim.cmd.lwindow()
        else
            vim.fn.setqflist(items)
            vim.cmd.cwindow()
        end
    end))
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
    desc = "Run shell command in floating terminal",
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
local lsp = vim.lsp
local lsp_complete_clients = function()
    return vim.tbl_map(function(client)
        return client.name
    end, lsp.get_clients { bufnr = 0 })
end

local iter_clients = function(buf, name)
    return ipairs(lsp.get_clients { bufnr = buf, name = name })
end

command("LspStop", function(args)
    local buf = api.nvim_get_current_buf()
    for _, client in iter_clients(buf, args.fargs[1]) do
        client:stop(args.bang)
    end
end, {
    desc = "Stop LSP servers",
    nargs = "*",
    bang = true,
    complete = lsp_complete_clients,
})

command("LspStart", function(args)
    lsp.start(lsp.config[args.args])
end, {
    desc = "Manually start LSP server",
    nargs = 1,
    complete = function()
        return vim.tbl_keys(lsp._enabled_configs)
    end
})

command("LspRestart", function(args)
    local detached = {}
    for _, client in iter_clients(api.nvim_get_current_buf(), args.fargs[1]) do
        if vim.tbl_count(client.attached_buffers) > 0 then
            detached[client.name] = { client, lsp.get_buffers_by_client_id(client.id) }
        end
        client:stop(args.bang)
    end
    local timer = assert(vim.uv.new_timer())
    timer:start(500, 100, vim.schedule_wrap(function()
        for name, info in pairs(detached) do
            ---@type vim.lsp.Client, integer[]
            local client, buffers = unpack(info)
            if client:is_stopped() then
                local new_id = assert(lsp.start(client.config, { attach = false }))
                for _, buf in pairs(buffers) do
                    lsp.buf_attach_client(buf, new_id)
                end
                detached[name] = nil
            end
        end

        if next(detached) == nil and not timer:is_closing() then
            timer:close()
        end
    end))
end, {
    desc = "Restart LSP servers",
    bang = true,
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

-- Utilities {{{
local SHEBANG_NAMES = {
    awk = "/usr/bin/env -S awk -f",
    bash = "/usr/bin/env bash",
    lua = "/usr/bin/env luajit",
    python = "/usr/bin/env python",
    sh = "/bin/sh",
    zsh = "/usr/bin/env zsh",
}

command("Shebang", function(args)
    local shebang
    if args.fargs[1] then
        shebang = SHEBANG_NAMES[args.args] or ("/usr/bin/env " .. args.args)
    else
        shebang = SHEBANG_NAMES[vim.bo.ft]
    end

    if not shebang then
        vim.notify("No shebang for " .. vim.bo.ft, vim.log.levels.ERROR)
        return
    end

    api.nvim_buf_set_lines(0, 0, 0, false, {
        "#!" .. shebang,
        ""
    })

    -- make the file executable when it's first written
    api.nvim_create_autocmd("BufWritePost", {
        command = "silent !chmod u+x %",
        buffer = 0,
        once = true,
    })
end, {
    desc = "Add a shebang for the current buffer",
    nargs = "*",
    complete = function()
        return vim.tbl_keys(SHEBANG_NAMES)
    end
})
-- }}}

command("Dash", function(args)
    require("config.dashboard").show()
end, { desc = "Open dashboard" })
