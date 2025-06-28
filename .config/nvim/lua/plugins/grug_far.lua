-- TODO: this seems quite cool, evaluate whether to use it
---@type LazySpec
local M = {
    "MagicDuck/grug-far.nvim",
}

---@type grug.far.OptionsOverride
M.opts = {
    folding = {
        enabled = false,
    },
    helpLine = {
        enabled = false,
    },
    icons = {
        enabled = false
    },
    resultLocation = {
        numberLabelFormat = " [%2d]",
    },
    keymaps = {}
}

return M
