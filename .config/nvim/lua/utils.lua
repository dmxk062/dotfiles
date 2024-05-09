local utils = {}

function utils.kitty_new_dir(path, type)
    vim.fn.jobstart(string.format("kitty @ launch --type=%s --cwd \"%s\" -- zsh -i", type, path))
end

return utils
