require("luasnip.loaders.from_vscode").lazy_load{ paths = vim.fn.stdpath "config" .. "/snippets/" }
ls=require("luasnip")
vim.keymap.set({"i", "s"}, "<S-Tab>", function() ls.jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-S-Tab", function() ls.jump(-1) end, {silent = true})
