local lspconfig = require('lspconfig')
-- lspconfig.marksman.setup{}
lspconfig.bashls.setup{}
lspconfig.tsserver.setup{}
lspconfig.asm_lsp.setup{}
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
lspconfig.jsonls.setup{capabilities=capabilities}
require'lspconfig'.html.setup {capabilities=capabilities}
require'lspconfig'.clangd.setup{capabilities=capabilities, cmd={"clangd"}}
-- lspconfig.pyright.setup{}
lspconfig.jedi_language_server.setup{}
lspconfig.ruff_lsp.setup{}
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<c-i>', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>a', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<space>fmt', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})
-- Server-specific settings. See `:help lspconfig-setup`
local _border = "rounded"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
vim.lsp.handlers.hover, {
    border = _border
}
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
vim.lsp.handlers.signature_help, {
    border = _border
}
)

vim.diagnostic.config{
    float={border=_border}
}
vim.cmd [[
highlight! DiagnosticLineNrError guibg=#2e3440 guifg=#bf616a gui=bold
highlight! DiagnosticLineNrWarn guibg=#2e3440 guifg=#d08770 gui=bold
highlight! DiagnosticLineNrInfo guibg=#2e3440 guifg=#5e81ac gui=bold
highlight! DiagnosticLineNrHint guibg=#2e3440 guifg=#81a1c1 gui=bold

sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
sign define DiagnosticSignHint text=󱩖 texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
" sign define DiagnosticSignError linehl= numhl=DiagnosticLineNrError
" sign define DiagnosticSignWarn  linehl= numhl=DiagnosticLineNrWarn
" sign define DiagnosticSignInfo  linehl= numhl=DiagnosticLineNrInfo
" sign define DiagnosticSignHint  linehl= numhl=DiagnosticLineNrHint
]]
vim.diagnostic.config({
    virtual_text = {
        prefix = '', -- Could be '●', '▎', 'x'
    }
})
-- vim.o.updatetime = 10
-- vim.cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
