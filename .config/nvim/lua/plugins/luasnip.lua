local M = {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    lazy = true,
    dependencies = {
        "rafamadriz/friendly-snippets" 
    },
}

M.config = function(_, opts)
    local ls = require("luasnip")
    local lsvs = require("luasnip.loaders.from_vscode")

    lsvs.lazy_load({ exclude = { "markdown", "all" } })
    lsvs.lazy_load({ paths = { vim.fn.stdpath "config" .. "/snippets/" } })

    local map = require("utils").map
    map({ "i", "s" }, "<M-Space>", function() ls.jump(1) end, { silent = true })
    map({ "i", "s" }, "<C-Space>", function() ls.jump(-1) end, { silent = true })
end

return M
