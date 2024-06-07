return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "b0o/schemastore.nvim",
    },
    event = {"BufReadPost"},
    config = function()
        local lspconfig = require('lspconfig')
        local utils = require("utils")

        require("lspconfig.ui.windows").default_options.border = "rounded"
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true
        }

        utils.map('n', '<space>d', vim.diagnostic.open_float)
        utils.map('n', '[d', vim.diagnostic.goto_prev)
        utils.map('n', ']d', vim.diagnostic.goto_next)
        -- utils.map('n', '<space>q', vim.diagnostic.setloclist)

        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
                -- require("inc_rename").setup {
                -- input_buffer_type = "dressing",
                -- hl_group = "IncrementalRename",
                -- hl_group = "Subsitute",
                -- }
                -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                local opts = { buffer = ev.buf }
                utils.map('n', 'gi', vim.lsp.buf.implementation, opts)
                -- utils.map('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                utils.map({ 'n', 'v' }, '<space>a', vim.lsp.buf.code_action, opts)
                -- utils.map('n', '<space>rn', function ()
                --     return ":IncRename " .. vim.fn.expand("<cword>")
                -- end, {expr = true})
                utils.map("n", "<space>rn", vim.lsp.buf.rename, opts)
                utils.map('n', '<space>fmt', function()
                    vim.lsp.buf.format { async = true }
                end, opts)
            end,
        })

        vim.diagnostic.config {
            float = { border = "rounded" }
        }
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
            vim.lsp.handlers.hover, {
                border = "rounded"
            }
        )
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
            vim.lsp.handlers.signature_help, {
                border = "rounded"
            }
        )

        local signs = {
            { name = "DiagnosticSignError", text = "󰅖" },
            { name = "DiagnosticSignWarn", text = "" },
            { name = "DiagnosticSignInfo", text = "󰋼" },
            { name = "DiagnosticSignHint", text = "󰟶" }
        }

        for _, sign in ipairs(signs) do
            vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
        end
        vim.diagnostic.config({
            virtual_text = {
                prefix = '!',
            }
        })


        -- individual lsps
        lspconfig.jsonls.setup {
            capabilities = capabilities,
            settings = {
                json = {
                    schemas = require("schemastore").json.schemas(),
                    validate = { enable = true },
                },
            },
        }
        lspconfig.lua_ls.setup {
            capabilities = capabilities,
            on_init = function(client)
                local path = client.workspace_folders[1].name
                -- we're editing some other lua project, not the nvim config
                if not vim.startswith(path, vim.fn.stdpath("config")) then
                    return
                end
                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                    runtime = {
                        version = 'LuaJIT'
                    },
                    workspace = {
                        checkThirdParty = false,
                        -- library = vim.api.nvim_get_runtime_file("", true), -- slow, has **everything**
                        library = {
                            -- dont get everything, only the stuff i truly care about
                            vim.env.VIMRUNTIME,
                            vim.fn.stdpath("config") .. "/lua"
                        }
                    }
                })
            end,
            settings = {
                Lua = {}
            }
        }
        lspconfig.clangd.setup {
            capabilities = capabilities,
            cmd = {
                "clangd", "--enable-config"
            },
            on_init = function()
                -- cycle between definition and implementation files
                utils.map("n", "<space>H", "<cmd>ClangdSwitchSourceHeader<CR>")
            end
        }
        lspconfig.bashls.setup {
            capabilities = capabilities,
        }
        lspconfig.tsserver.setup {
            capabilities = capabilities,
        }
        lspconfig.asm_lsp.setup {
            capabilities = capabilities,
            root_dir = function(path)
                if vim.uv.fs_stat(".asm-lsp.toml") then
                    return "."
                else
                    return require("lspconfig.util").find_git_ancestor(path)
                end
            end
        }
        lspconfig.html.setup {
            capabilities = capabilities
        }
        lspconfig.jedi_language_server.setup {
            capabilities = capabilities
        }
        -- lspconfig.pyright.setup{
        --     capabilities = capabilities
        -- }
        lspconfig.ruff_lsp.setup {
            capabilities = capabilities
        }
        lspconfig.marksman.setup {
            capabilities = capabilities
        }
    end,
}
