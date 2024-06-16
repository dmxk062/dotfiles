return {
    "stevearc/dressing.nvim",
    opts = {
        input = {
            insert_only = false,
            default_prompt = "Input",
            trim_prompt = false,
        },
        select = {
            enabled = true,
            backend = { "builtin", "telescope" },
            builtin = {
                max_height = {12, 0},
                min_height = {2,  0},
                relative = "cursor",
                override = function (opts)
                    opts.row = opts.row + 1
                    return opts
                end,
            },
        },

    }
}
