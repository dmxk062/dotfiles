-- TODO: this seems quite cool, evaluate whether to use it
---@type LazySpec
local M = {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
}

---@type grug.far.OptionsOverride
M.opts = {
    helpLine = {
        enabled = false,
    },
    icons = {
        enabled = false
    },
    resultLocation = {
        showNumberLabel = false,
    },
    keymaps = { }
}

return M
