---@type LazySpec
local M = {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<space>p",
            function()
                require("conform").format { async = true }
            end,
            mode = { "n", "x" }
        }
    }
}

---@type conform.setupOpts
M.opts = {
    formatters_by_ft = {
        lua  = { "stylua" },
        c    = { "clang-format" },
        go   = { "gofmt" },
        json = { "jq" },
        bash = { "shfmt" },
        _    = { "trim_whitespace" },
    },
    default_format_opts = {
        lsp_format = "fallback"
    },
    formatters = {
        jq = {
            inherit = true,
            -- make jq respect shiftwidth
            append_args = function(self, ctx)
                if vim.bo[ctx.buf].expandtab then
                    local width = ctx.shiftwidth
                    if width > 7 then
                        vim.notify("Jq only supports up to 7 spaces indent", vim.log.levels.WARN)
                        width = 7
                    end
                    return { "--indent", tostring(width) }
                else
                    return { "--tab" }
                end
            end
        },
        shfmt = {
            inherit = true,
            append_args = function(self, ctx)
                if vim.bo[ctx.buf].expandtab then
                    return tostring(ctx.shiftwidth)
                else
                    return "0"
                end
            end
        }
    }
}

return M
