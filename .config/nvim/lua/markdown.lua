-- markdown-preview
vim.g.mkdp_auto_start = false
vim.g.mkdp_page_title = "Preview ${name}"
vim.g.mkdp_theme = ""
vim.g.mkdp_markdown_css = (vim.fn.stdpath("config") .. "/style/markdown.css")
-- vim.g.mkdp_markdown_css = (vim.fn.stdpath("config") .. "/style/highlight.css")

-- require("render-markdown").setup {
--     start_enabled = true,
-- }

require("headlines").setup({
    markdown = {
        headline_highlights = {
            "Headline1",
            "Headline2",
            "Headline3",
            "Headline4",
            "Headline5",
            "Headline6",
        },
        bullets = {""},
        dash_string = "-",
        codeblock_highlight = "CodeBlock",
        dash_highlight = "Dash",
        quote_highlight = "Quote",
    },
})

