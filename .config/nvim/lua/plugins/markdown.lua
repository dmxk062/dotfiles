local M = {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && yarn install",
    config = function()
        vim.g.mkdp_auto_start = false
        vim.g.mkdp_page_title = "Preview ${name}"
        vim.g.mkdp_theme = ""
        vim.g.mkdp_markdown_css = (vim.fn.stdpath("config") .. "/style/markdown.css")
    end
}

return M
