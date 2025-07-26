-- TODO: this seems quite cool, evaluate whether to use it
---@type LazySpec
local M = {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" }
}

---@type grug.far.OptionsOverride
M.opts = {
    showCompactInputs = true,
    showInputsTopPadding = false,
    showInputsBottomPadding = false,
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
        numberLabelPosition = "right_align",
        numberLabelFormat = " %d",
    },
    resultsSeparatorLineChar = "─",
    keymaps = {},
    windowCreationCommand = "Split",
}

M.init = function()
    Jhk.ensure_program("ast-grep")
end

return M
