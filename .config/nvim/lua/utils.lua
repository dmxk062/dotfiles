local M = {}



--- tries to open a shell in the correct directory that the current file is in
---@param uri string
---@param type? "window"|"os-window"|"tab"|"overlay"
---@param opts {location: "split"|"hsplit"|"vsplit"} | nil
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

---@alias nvim_mode "n"|"i"|"c"|"v"|"x"|"s"|"o"|"t"|{}

---@param mode nvim_mode
---@param keys string
---@param action string|function
---@param opts vim.keymap.set.Opts|nil
function M.map(mode, keys, action, opts)
    vim.keymap.set(mode, keys, action, opts or {})
end

---@param mode nvim_mode
---@param keys string
---@param opts vim.keymap.del.Opts?
function M.unmap(mode, keys, opts)
    vim.keymap.del(mode, keys, opts or {})
end

---@param bufnr integer
---@param mode nvim_mode
---@param keys string
---@param opts vim.keymap.del.Opts?
function M.lunmap(bufnr, mode, keys, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.del(mode, keys, opts)
end

---@param bufnr integer
---@param mode nvim_mode
---@param keys string
---@param action string|function
---@param opts vim.keymap.set.Opts|nil
function M.lmap(bufnr, mode, keys, action, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, keys, action, opts)
end

---@param bufnr integer
---@param prefix string?
---@return fun(mode: nvim_mode, keys: string, action: string|function, opts: vim.keymap.set.Opts?)
function M.local_mapper(bufnr, prefix)
    if prefix then
        return function(mode, keys, action, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, prefix .. keys, action, opts)
        end
    else
        return function(mode, keys, action, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, keys, action, opts)
        end
    end
end

---@param mode nvim_mode
---@param keys string
---@param string string
function M.abbrev(mode, keys, string)
    if type(mode) == "table" then
        vim.keymap.set(vim.tbl_map(function(s)
            return s .. "a"
        end, mode), keys, string)
    else
        vim.keymap.set(mode .. "a", keys, string)
    end
end

return M
