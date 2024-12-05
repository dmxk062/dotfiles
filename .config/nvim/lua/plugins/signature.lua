local M = {
    "ray-x/lsp_signature.nvim",
}

M.opts = {
    doc_lines = 6,
    max_width = 60,
    close_timeout = 1000,
    hint_enable = false,
}

M.config = function(_, opts)
    require("lsp_signature").setup(opts)
end

return M
