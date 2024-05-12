local M = {}


-- tries to open a shell in the correct directory that the current file is in
function M.kitty_shell_in(uri, type, position)
    position = position or "split"
    local cmd
    if uri:sub(1, #"oil-ssh://") == "oil-ssh://" then -- we're connected via ssh
        local addr = uri:match("//(.-)/") -- host
        local remote_path = uri:match("//.-(/.*)"):sub(2, -1) -- the path at the host

        -- assumes a POSIX-ish shell to be present
        -- ssh -t makes sure we get a vtty even though it looks like we're "just" running a command
        cmd = string.format([[ -- ssh -t '%s' -- cd '%s'\; exec '${SHELL:=/bin/sh}']], addr, remote_path)
    else
        cmd = " --cwd '" .. uri .. "' -- zsh -i"
    end
    vim.fn.jobstart("kitty @ launch --type=" .. type .. " --location=" ..position .. cmd)
end

-- function M.kitty_new_dir(path, type)
--     vim.fn.jobstart(string.format("kitty @ launch --type=%s --cwd \"%s\" -- zsh -i", type, path))
-- end
--
-- function M.kitty_new_cmd(cmd, type)
--     vim.fn.jobstart("kitty @ launch --type=" .. type .. " -- " .. cmd)
-- end

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
    vim.api.nvim_command(mode .. "abbrev" .. " " .. keys .. " " .. string)
end



return M
