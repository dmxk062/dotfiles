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
        max_height = 6, -- don't show too many lines
        -- i dont care about using nvim as a file viewer, also makes lazy loading possible
        hijack_file_patterns = {},
        integrations = {
            markdown = {
                -- otherwise quickly becomes annoying or slow
                only_render_image_at_cursor = true,
            }
        }
    }
}

return M
