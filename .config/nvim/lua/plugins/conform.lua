local M = {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<space>fmt",
            function()
                require("conform").format { async = true }
            end,
            mode = { "n", "x" }
        }
    }
}

M.opts = {
    formatters_by_ft = {
        lua  = { "stylua" },
        c    = { "clang-format" },
        json = { "jq" }
    },
    default_format_opts = {
        lsp_format = "fallback"
    }
}

return M
