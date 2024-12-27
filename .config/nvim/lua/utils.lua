local M = {}



--- tries to open a shell in the correct directory that the current file is in
---@param opts {location: "split"|"hsplit"|"vsplit", what: "window"|"os-window"|"tab"|"overlay"} | nil
function M.kitty_shell_in(opts)
    local bname = vim.api.nvim_buf_get_name(0)
    opts = opts or {}
    local location = opts.location or "split"
    local what = opts.what or "window"

    local cmd = { "kitty", "@", "launch", "--type=" .. what, "--location=" .. location }

    if vim.startswith(bname, "oil-ssh://") then
        local addr = bname:match("//(.-)/")
        local remote_path = bname:match("//.-(/.*)"):sub(2, -1)
        vim.list_extend(cmd, { "--", "ssh", "-t", addr, "--", "cd", remote_path, ";", "exec", "${SHELL:-/bin/sh}" })
    elseif vim.startswith(bname, "oil://") then
        vim.list_extend(cmd, { "--cwd", require("oil").get_current_dir() })
    else
        vim.list_extend(cmd, { "--cwd", vim.fn.fnamemodify(bname, ":p:h") })
    end
    vim.system(cmd, { detach = true })
end

---@param opts {location: "horizontal"|"vertical"|"tab"} | nil
function M.nvim_term_in(opts)
    local bname = vim.api.nvim_buf_get_name(0)
    opts = opts or {}
    local cmd
    local cwd = ""
    if vim.startswith(bname, "oil-ssh://") then
        local addr, remote_path = bname:match("//(.-)(/.*)")
        cmd = { "ssh", "-t", addr, "--", "cd", remote_path:sub(2, -1), ";", "exec", "${SHELL:-/bin/sh}" }
    elseif vim.startswith(bname, "oil://") then
        cmd = { vim.o.shell }
        cwd = require("oil").get_current_dir()
    else
        cmd = { vim.o.shell }
        cwd = vim.fn.fnamemodify(":p:h", bname)
    end


    vim.cmd((opts.location or "") .. " new")
    vim.fn.termopen(cmd, { cwd = cwd })
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
