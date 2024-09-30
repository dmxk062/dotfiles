local rocks = {
    "magick",
}
local M = {
    "vhyrro/luarocks.nvim",
    cmd = { "RocksInstall" },
    lazy = true,
    opts = {
        rocks = rocks
    },
}

return M
