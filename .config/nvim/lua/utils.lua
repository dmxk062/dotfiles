local utils = {}

function utils.kitty_new_dir(path, type)
    vim.fn.jobstart(string.format("kitty @ launch --type=%s --cwd \"%s\" -- zsh -i", type, path))
end

function utils.map(mode, keys, action, opts) 
    vim.keymap.set(mode, keys, action, opts or {})
end

-- map locally for only one buffer
function utils.lmap(bufnr, mode, keys, action, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, keys, action, opts)
end

function utils.abbrev(mode, keys, string)
    vim.api.nvim_command(mode .. "abbrev" .. " " .. keys .. " " .. string)
end



return utils
