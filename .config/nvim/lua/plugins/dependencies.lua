return {
    { "nvim-lua/plenary.nvim",       lazy = true },
    { "nvim-tree/nvim-web-devicons", lazy = true },
    {
        "vhyrro/luarocks.nvim",
        lazy = true,
        cmd = { "RocksInstall" },
        opts = {
            rocks = {
                "magick"
            }
        }
    }
}
