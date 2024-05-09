local lspconfig = require('lspconfig')
-- lspconfig.marksman.setup{}
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.bashls.setup{capabilities=capabilities}
lspconfig.tsserver.setup{capabilities=capabilities}
lspconfig.asm_lsp.setup{capabilities=capabilities}
lspconfig.html.setup {capabilities=capabilities}
lspconfig.clangd.setup{capabilities=capabilities, cmd={"clangd", "--enable-config"}}
-- lspconfig.pyright.setup{}
lspconfig.jedi_language_server.setup{capabilities=capabilities}
lspconfig.ruff_lsp.setup{capabilities=capabilities}
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>d', vim.diagnostic.open_float)
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

local signs = {
    {name = "DiagnosticSignError", text = "󰅖"},
    {name = "DiagnosticSignWarn", text = ""},
    {name = "DiagnosticSignInfo", text = "󰋼"},
    {name = "DiagnosticSignHint", text = "󰟶"}
}

for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, {texthl = sign.name, text = sign.text, numhl = sign.name})
end
vim.diagnostic.config({
    virtual_text = {
        prefix = '', -- Could be '●', '▎', 'x'
    }
})

lspconfig.jsonls.setup{
    capabilities = capabilities,
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = {enable = true},
        },
    },
}
