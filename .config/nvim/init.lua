vim.cmd("source" .. vim.fn.stdpath("config") .. "/pkgs.vim")
vim.g.nord_italic = true
vim.g.nord_borders = true
vim.cmd("colorscheme nord")

vim.o.number = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.noshowmode = true
vim.o.smartcase = true
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.hlsearch = true
vim.o.termguicolors = true
vim.o.wildmenu = false
vim.o.wrap = true


vim.o.guicursor = "c-ci-cr:hor20,n-o-r-v-sm:block,i-ve:ver10,n-i-ve:blinkon1,"
vim.o.cursorline = true
vim.o.cursorlineopt = "number"

vim.o.title = true
vim.o.titlestring = "nv: %F"

vim.o.wrap = true




require("mappings")
require("plugins")
