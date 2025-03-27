local M = {
    "williamboman/mason.nvim",
    opts = {
        ui = {
            width = 0.8,
            height = 0.8,

            icons = {
                package_installed   = "󱝍",
                package_pending     = "󱝏",
                package_uninstalled = "󱝋",
            }
        }
    }
}

return M
