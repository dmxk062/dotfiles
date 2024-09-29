local M = {
    "mbbill/undotree"
}

M.config = function()
    local utils = require("utils")
    utils.map("n", "<space>u", vim.cmd.UndotreeToggle)

    vim.g.undotree_ShortIndicators = true
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_SetFocusWhenToggle = true
    vim.g.undotree_DiffAutoOpen = false
    vim.g.undotree_HelpLine = false
    vim.g.undotree_TreeNodeShape = "│"
    vim.g.undotree_TreeVertShape = "╷"
    vim.g.undotree_TreeSplitShape = "⟋"
    vim.g.undotree_TreeReturnShape = "⟍"
end

return M
