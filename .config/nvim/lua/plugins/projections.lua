-- TODO: evaluate https://github.com/stevearc/resession.nvim
---@type LazySpec
local M = {
    "GnikDroy/projections.nvim",
    branch = "dev",
    keys = {},
    opts = {
        workspaces = {
            { path = "~/ws/",     patterns = { ".git" } },
            { path = "~/.config", patterns = { ".git", ".luarc.json" } },
        },

        -- ~/.cache is on a tmpfs
        sessions_directory = vim.fn.stdpath("state") .. "/projections/"
    }
}

return M
