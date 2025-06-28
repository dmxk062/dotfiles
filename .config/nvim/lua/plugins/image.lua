---@type LazySpec
local M = {
    "3rd/image.nvim",
    rocks = {
        "magick"
    },
    lazy = true,
    ft = { "markdown", "typst", "html", "neorg" },
    opts = {
        processor = "magick_rock",
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = {},
        max_width = 80,
        max_height = 6,
        hijack_file_patterns = {},
        integrations = {
            markdown = {
                -- do not show them by default
                enabled = false,
            }
        }
    }
}

return M
