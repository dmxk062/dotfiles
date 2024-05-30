vim.g.vimtex_view_method = 'zathura'
-- vim.g.vimtex_compiler_latexmk_engines = {_ = "-xelatex"}
vim.g.vimtex_compiler_latexmk = {
    aux_dir = ".aux",
    out_dir = "build",
}

local cmp = require('cmp')
cmp.setup.filetype('tex', {
    sources = cmp.config.sources({
        { name = 'vimtex'},
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'buffer' },
        { name = 'nvim_lsp' },
        { name = 'spell' } -- move spell to the bottom so it doesnt slow it down that much
    })
})

