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

local function put_result(res)
    if (res) then
        vim.api.nvim_put(vim.split(tostring(res), "\n"), "c", false, false)
    end
end

function M.NOOP()
end

-- evaluate a lua expression and insert the result
-- useful for math
function M.insert_eval_lua(motion)
    local buf = vim.api.nvim_get_current_buf()

    -- called from the direct mapping, not dot completion
    if not motion then
        -- reset the last expression
        vim.b[buf].last_expr = nil
        -- tell nvim to call our callback on g@
        vim.go.operatorfunc = "v:lua.require'utils'.insert_eval_lua_callback"
        -- needs to me mapped with {expr = true}, calls the callback
        return "g@l"
    end
    -- insert the evaluated expression into the buffer vim.v.count times
    for _ = 0, vim.v.count do
        put_result(vim.b[buf].last_expr())
    end
end

function M.insert_eval_lua_callback()
    local buf = vim.api.nvim_get_current_buf()

    -- not dot repeat
    if not vim.b[buf].last_expr then
        vim.ui.input({prompt = "Evaluate Lua"}, function(input)
            vim.b[buf].last_expr = load("return " .. (input or ""))

            -- set the last used command to "g@l" so repeat works
            vim.go.operatorfunc = "v:lua.require'utils'.NOOP"
            vim.api.nvim_command("normal! g@l")

            -- set the operatorfunc back to our handler
            vim.go.operatorfunc = "v:lua.require'utils'.insert_eval_lua_callback"

            -- call the main function, repeated cause vim.ui.input is async
            M.insert_eval_lua(true)
        end)
    else
        -- repeat
        M.insert_eval_lua(true)
    end
end


return M
