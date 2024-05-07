local ls=require("luasnip")
local lsvs=require("luasnip.loaders.from_vscode")

lsvs.lazy_load({ exclude = { "markdown" }})
lsvs.lazy_load({ paths = {vim.fn.stdpath "config" .. "/snippets/"} })

vim.keymap.set({"i", "s"}, "<S-Tab>", function() ls.jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-S-Tab", function() ls.jump(-1) end, {silent = true})
