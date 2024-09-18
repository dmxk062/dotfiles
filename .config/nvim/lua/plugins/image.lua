local M = {
    "3rd/image.nvim",
    lazy = true,
    ft = { "markdown" },
    opts = {
        -- dont show images when e.g. a cmp popup is above them
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = {},
        -- show max of eighty columns, 16:9 aspect ratio
        max_width = 80,
        max_height = 45,
        -- i dont care about using nvim as a file viewer, also makes lazy loading possible
        hijack_file_patterns = {},
    },
    dependencies = {
        "vhyrro/luarocks.nvim",
    }
}

return M
