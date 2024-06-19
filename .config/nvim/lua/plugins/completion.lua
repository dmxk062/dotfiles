M = {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-omni",
        "saadparwaiz1/cmp_luasnip",
        "onsails/lspkind.nvim",
        "f3fora/cmp-spell",
        {
            "L3MON4D3/LuaSnip",
            build = "make install_jsregexp",
            dependencies = { "rafamadriz/friendly-snippets" },
            config = function()
                local ls = require("luasnip")
                local lsvs = require("luasnip.loaders.from_vscode")

                lsvs.lazy_load({ exclude = { "markdown", "all" } })
                lsvs.lazy_load({ paths = { vim.fn.stdpath "config" .. "/snippets/" } })

                vim.keymap.set({ "i", "s" }, "<S-Tab>", function() ls.jump(1) end, { silent = true })
                vim.keymap.set({ "i", "s" }, "<C-S-Tab", function() ls.jump(-1) end, { silent = true })
            end
        },
    }
}
M.config = function()
    local lspkind = require("lspkind")
    local cmp = require("cmp")

    cmp.setup({
        performance = {
            max_view_entries = 24,
        },
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end,
        },
        formatting = {
            format = lspkind.cmp_format({
                mode = "symbol",
                before = function (entry, vim_item)
					if entry.source.name == "vimtex" then
						vim_item.kind = "Latex"
					end
                    return vim_item
                end,
                symbol_map = {
                    Text = "󰉿 txt",
                    Method = "󰆧 method",
                    Function = "󰊕 func",
                    Constructor = " constructor",
                    Field = "󰽐 field",
                    Variable = "α var",
                    Class = "󰠱 class",
                    Interface = " type",
                    Module = " module",
                    Property = "󰜢 prop",
                    Unit = "󰑭 unit",
                    Value = "󰎠 val",
                    Enum = " enum",
                    Keyword = "󰌋 keywd",
                    Snippet = " snip",
                    Color = "󰏘 color",
                    File = "󰈙 file",
                    Reference = "󰈇 ref",
                    Folder = " dir",
                    EnumMember = " enum",
                    Constant = "󰏿 const",
                    Struct = "󰙅 struct",
                    Event = " event",
                    Operator = "󰆕 op",
                    TypeParameter = " param",
					Latex = " tex",
                },
            }),
        },
        window = {
            completion = {
                border = "rounded",
                winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                scrollbar = false,
            },
            documentation = {
                border = "rounded",
                winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:CursorLine,Search:None",
                scrollbar = false,
            }
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<M-j>"] = cmp.mapping.select_next_item(),
            ["<M-k>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "path" },
            { name = "buffer" },
        }
    })

    cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
            { name = "git" },
        }, {
            { name = "buffer" },
        })
    })


    cmp.setup.filetype("markdown", {
        sources = cmp.config.sources({
            { name = "luasnip" },
            { name = "path" },
            { name = "buffer" },
            { name = "nvim_lsp" },
            { name = "spell" }     -- move spell to the bottom so it doesnt slow it down that much
        })
    })
    cmp.setup.cmdline({"/", "?"}, {
        mapping = cmp.mapping.preset.cmdline({}),
        sources = cmp.config.sources ({
            { name = "buffer" },
        })
    })

    cmp.setup.cmdline({ ":" }, {
        mapping = cmp.mapping.preset.cmdline({}),
        sources = cmp.config.sources({
            { name = "path" },
            {
                name = "cmdline",
                option = {
                    ignore_cmds = {}
                }
            },
        })
    })
    cmp.setup.filetype("DressingInput", {
        sources = cmp.config.sources({
            { name = "omni" },
        })
    })
    cmp.setup.filetype("oil", {
        sources = cmp.config.sources({
            {
                name = "path",
                option = {
                    get_cwd = function()
                        -- local pwd if ssh
                        return require("oil").get_current_dir() or vim.fn.getcwd()
                    end
                }
            },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "nvim_lsp" },
        })
    })
end

return M
