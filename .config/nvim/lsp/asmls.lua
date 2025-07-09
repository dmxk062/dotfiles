---@type vim.lsp.Config
return {
    filetypes = { "asm", "vmasm" },
    cmd = { "asm-lsp" },
    root_markers = { ".asm-lsp.toml", ".git" },
}
