local M = {
    "neovim/nvim-lspconfig",
    dependencies = {
        "b0o/schemastore.nvim",
    },
    event = {"BufReadPost"}
}

M.config = function()
    local lspconfig = require("lspconfig")
    local utils = require("utils")

    require("lspconfig.ui.windows").default_options.border = "rounded"
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
    }

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(opts)

            local textobjs = require("textobjs")
            -- target a lsp diagnostic as a textobject
            utils.lmap(opts.buf, {"x", "o"}, "idd", textobjs.diagnostic)
            utils.lmap(opts.buf, {"x", "o"}, "ide", function() textobjs.diagnostic("error") end)
            utils.lmap(opts.buf, {"x", "o"}, "idw", function() textobjs.diagnostic("warn") end)
            utils.lmap(opts.buf, {"x", "o"}, "idi", function() textobjs.diagnostic("info") end)
            utils.lmap(opts.buf, {"x", "o"}, "idh", function() textobjs.diagnostic("hint") end)


            utils.lmap(opts.buf, "n", "<space>d", vim.diagnostic.open_float)
            utils.lmap(opts.buf, "n", "[d", vim.diagnostic.goto_prev)
            utils.lmap(opts.buf, "n", "]d", vim.diagnostic.goto_next)

            utils.lmap(opts.buf, "n", "gi", vim.lsp.buf.implementation)
            utils.lmap(opts.buf, { "n", "v" }, "<space>a", vim.lsp.buf.code_action)
            utils.lmap(opts.buf, "n", "<space>rn", vim.lsp.buf.rename)
            utils.lmap(opts.buf, "n", "<space>fmt", function() vim.lsp.buf.format { async = true } end)
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
            prefix = "!",
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
            client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                runtime = {
                    version = "LuaJIT"
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
        on_init = function(client)
            -- cycle between definition and implementation files
            utils.lmap(vim.api.nvim_get_current_buf(), "n", "<space>H", "<cmd>ClangdSwitchSourceHeader<CR>")
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
    lspconfig.taplo.setup {
        capabilities = capabilities
    }
end

return M
