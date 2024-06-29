local groups = require("theme.groups")
local M = {}

function M.load()
    for _, colors in pairs(groups) do
        for name, group in pairs(colors) do
            vim.api.nvim_set_hl(0, name, group)
        end
    end
end

return M
