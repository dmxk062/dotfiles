local groups = require("theme.groups")
local M = {}

function M.load()
    for name, group in pairs(groups) do
        vim.api.nvim_set_hl(0, name, group)
    end
end

return M
