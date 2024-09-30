return {
    "lervag/vimtex",
    ft = { "latex", "tex" },
    config = function()
        vim.g.vimtex_view_method = "zathura"
        -- vim.g.vimtex_compiler_latexmk_engines = {_ = "-xelatex"}
        vim.g.vimtex_compiler_latexmk = {
            aux_dir = ".aux",
            out_dir = "build",
        }

        local cmp = require("cmp")
        cmp.setup.filetype("tex", {
            sources = cmp.config.sources({
                { name = "vimtex" },
                { name = "luasnip" },
                { name = "path" },
                { name = "buffer" },
                { name = "nvim_lsp" },
                { name = "spell" } -- move spell to the bottom so it doesnt slow it down that much
            })
        })

        vim.api.nvim_create_autocmd("BufEnter", {
            pattern = "*.tex",
            callback = function()
                vim.cmd("VimtexCompile")
                vim.wo.spell = true
                vim.bo.spelllang = "en_us"
            end
        })
    end,
    dependencies = { "micangl/cmp-vimtex" }
}
