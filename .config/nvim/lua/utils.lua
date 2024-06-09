local M = {}


-- tries to open a shell in the correct directory that the current file is in
function M.kitty_shell_in(uri, type, opts)
    opts = opts or {}
    local location = opts.location or "split"

    local cmd = { "kitty", "@", "launch", "--type=" .. type, "--location=" .. location }

    if uri:sub(1, #"oil-ssh://") == "oil-ssh://" then -- we're connected via ssh
        local addr = uri:match("//(.-)/")
        local remote_path = uri:match("//.-(/.*)"):sub(2, -1)

        -- assumes a POSIX-ish shell to be present, realistically we just need it to be able to cd and exec
        -- ssh -t makes sure we get a vtty even though it looks like we're "just" running a command
        vim.list_extend(cmd, { "--", "ssh", "-t", addr, "--", "cd", remote_path, ";", "exec", "${SHELL:-/bin/sh}" })
    else
        vim.list_extend(cmd, { "--cwd", uri })
    end
    vim.system(cmd, { detach = true })
end

function M.map(mode, keys, action, opts)
    vim.keymap.set(mode, keys, action, opts or {})
end

-- map locally for only one buffer
function M.lmap(bufnr, mode, keys, action, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, keys, action, opts)
end

function M.abbrev(mode, keys, string)
    vim.keymap.set(mode .. "a", keys, string)
end

-- evaluate a lua expression and insert the result
-- useful for math
function M.insert_eval_lua()
    vim.ui.input({prompt = "Evaluate Lua"}, function (input)
        local res = load("return " .. (input or ""))()
        if (res) then
            vim.api.nvim_put(vim.split(tostring(res), "\n"), "c", false, false)
        end
    end)
end

return M
