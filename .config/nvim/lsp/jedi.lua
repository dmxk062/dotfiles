---@type vim.lsp.Config
return {
    filetypes = { "python" },
    cmd = { "jedi-language-server" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
}
