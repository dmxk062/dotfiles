---@type vim.lsp.Config
return {
    filetypes = { "toml" },
    cmd = { "taplo", "lsp", "stdio" },
    root_markers = { ".git" },
}
