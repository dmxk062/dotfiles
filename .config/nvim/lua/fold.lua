vim.o.foldcolumn = '1'-- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
-- vim.o.fillchars = [[eob:~,fold:—,foldopen:-,foldsep:│,foldclose:+]]
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zC', require('ufo').closeAllFolds)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}
local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
for _, ls in ipairs(language_servers) do
    require('lspconfig')[ls].setup({
        capabilities = capabilities
        -- you can add other fields for setting up lsp server in this table
    })
end
local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = ('  %d lines...'):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local hlGroup = 'Comment'
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            table.insert(newVirtText, {chunkText, hlGroup})
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, {suffix, 'Comment'})
    return newVirtText
end
require('ufo').setup({
    open_fold_hl_timeout = 150,
    fold_virt_text_handler = handler,
    preview = {
        win_config = {
            border="rounded",
            winblend = 0
        },
        mappings = {
            scrollU = '<C-k>',
            scrollD = '<C-j>',
            jumpTop = '[',
            jumpBot = ']'
        }
    },
})
vim.keymap.set('n', 'K', function()
    local winid = require('ufo').peekFoldedLinesUnderCursor()
    if not winid then
        -- choose one of coc.nvim and nvim lsp
        vim.lsp.buf.hover()
    end
end)
local builtin = require("statuscol.builtin")
require("statuscol").setup({
    segments = {
    { text = { "%s" }, click = "v:lua.ScSa" },
    { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
    {
      text = { builtin.lnumfunc, " " },
      condition = { true, builtin.not_empty },
      click = "v:lua.ScLa",
    }
  },
})
require("ibl").setup {
}
