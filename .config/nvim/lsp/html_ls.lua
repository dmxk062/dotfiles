---@type vim.lsp.Config
return {
    filetypes = { "html" },
    cmd = { "vscode-html-language-server", "--stdio" },
    init_options = {
        provideFormatter = true,
        embeddedLanguages = { css = true, javascript = true },
        configurationSection = { "html", "css", "javascript" },
    }
}
