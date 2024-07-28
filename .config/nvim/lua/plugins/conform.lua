local M = {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<space>fm",
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
    },
    formatters = {
        jq = {
            inherit = true,
            -- make jq conform to vims prefered tab width
            append_args = { "--indent", vim.o.tabstop <= 7 and tostring(vim.o.tabstop) or 4 },
        }
    }
}

return M
