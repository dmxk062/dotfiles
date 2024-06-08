local fts = { "css", "scss", "sass", "html" }
return {
    "NvChad/nvim-colorizer.lua",
    event = "BufEnter",
    ft = fts,
    cmd = { "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers", "ColorizerToggle" },
    config = function()
        require("colorizer").setup {
            filetypes = fts,
            user_default_options = {
                RGB = true,
                RRGGBB = true,
                names = false,
                RRGGBBAA = true,
                AARRGGBB = true,
                rgb_fn = true,
                hsl_fn = true,
                css = true,
                css_fn = true,
                mode = "background",
                tailwind = false,
                virtualtext = "",
                always_update = false
            },
            bufftypes = {},
        }
    end
}
