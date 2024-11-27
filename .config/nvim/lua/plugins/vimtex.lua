return {
    "lervag/vimtex",
    ft = { "latex", "tex" },
    config = function()
        vim.g.vimtex_view_method = "zathura"
        vim.g.vimtex_compiler_latexmk_engines = {
            _ = "-lualatex"
        }
        vim.g.vimtex_compiler_latexmk = {
            aux_dir = ".aux",
            out_dir = "build",
        }


        local cmp_vimtex = require("cmp_vimtex")
        cmp_vimtex.setup({
        })

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

        vim.keymap.set("i", "<C-/>", function()
            require("cmp_vimtex.search").search_menu()
        end)



        local group = vim.api.nvim_create_augroup("vimtex_events", {})

        vim.api.nvim_create_autocmd("BufEnter", {
            pattern = "*.tex",
            callback = function(opts)
                -- vim.wo.spell = true
                -- vim.bo.spelllang = "en_us"
                vim.cmd("syntax on")
                vim.cmd("TSDisable highlight")
            end
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "VimtexEventInitPost",
            group = group,
            callback = function(ev)
                vim.cmd("VimtexCompile")
                -- send a bell to focus the window
                vim.api.nvim_create_autocmd("User", {
                    once = true,
                    pattern = "VimtexEventCompileSuccess",
                    callback = function()
                        vim.defer_fn(function()
                            vim.uv.new_tty(1, false):write("\a")
                        end, 500)
                    end
                })
            end
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "VimtexEventQuit",
            group = group,
            callback = function(ev)
                vim.cmd("VimtexClean")
            end
        })
    end,
    dependencies = { "micangl/cmp-vimtex" }
}
