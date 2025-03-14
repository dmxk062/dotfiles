return {
    "stevearc/dressing.nvim",
    opts = {
        input = {
            insert_only = false,
            default_prompt = "Input",
            trim_prompt = false,
            relative = "win",
            override = function(opts)
                opts.col = 6
                opts.row = vim.o.lines - 3
                return opts
            end,
        },
        select = {
            enabled = true,
            backend = { "builtin", "telescope" },
            builtin = {
                max_height = { 12, 0 },
                min_height = { 4, 0 },
                relative = "win",
                override = function(opts)
                    opts.col = 0
                    opts.row = vim.o.lines - 3
                    return opts
                end,
            },
        },

    }
}
