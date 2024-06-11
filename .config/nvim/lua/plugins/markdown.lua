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
M.dependencies = {
    {
        "lukas-reineke/headlines.nvim",
        opts = {
            markdown = {
                headline_highlights = {
                    "Headline1",
                    "Headline2",
                    "Headline3",
                    "Headline4",
                    "Headline5",
                    "Headline6",
                },
                bullets = { "" },
                dash_string = "-",
                codeblock_highlight = "CodeBlock",
                dash_highlight = "Dash",
                quote_highlight = "Quote",
            },
        }
    },
}

return M
