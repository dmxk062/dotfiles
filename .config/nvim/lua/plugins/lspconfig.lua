local M = {
    "neovim/nvim-lspconfig",
    dependencies = {
        "b0o/schemastore.nvim",
        {
            "williamboman/mason.nvim",
            config = function()
                require("mason").setup {
                    ui = {
                        border = "rounded",
                        width = 0.8,
                        height = 0.8,

                        icons = {
                            package_installed   = "󱝍",
                            package_pending     = "󱝏",
                            package_uninstalled = "󱝋",
                        }
                    }
                }

                require("mason-lspconfig").setup {
                    ensure_installed = {
                        "ruff_lsp",
                        "asm_lsp"
                    }
                }
            end,
            cmd = { "Mason", "MasonUpdate", "MasonInstall", "MasonUninstall", "MasonLog", "MasonUninstallAll" },
            dependencies = {
                "williamboman/mason-lspconfig.nvim",
            },
        }
    },
    event = { "BufReadPost" }
}


M.config = function()
    local lspconfig = require("lspconfig")
    local utils = require("utils")

    require("lspconfig.ui.windows").default_options = {
        border = "rounded"
    }
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
    }

    local augroup = vim.api.nvim_create_augroup("UserLspConfig", {})
    vim.api.nvim_create_autocmd("LspAttach", {
        group = augroup,
        callback = function(opts)
            local map = utils.local_mapper(opts.buf)
            map({ "n", "v" }, "<space>a", vim.lsp.buf.code_action)
            map("n", "<space>rn", vim.lsp.buf.rename)

            map("n", "gr", require("telescope.builtin").lsp_references)
            map("n", "gd", require("telescope.builtin").lsp_definitions)
            map("n", "<C-w>gd", "<C-w>v<C-]>")
            map("n", "gi", require("telescope.builtin").lsp_implementations)

            vim.api.nvim_buf_create_user_command(opts.buf, "InlayHint", function(args)
                if args.fargs[1] then
                    if args.fargs[1] == "on" then
                        vim.lsp.inlay_hint.enable(true)
                    elseif args.fargs[1] == "off" then
                        vim.lsp.inlay_hint.enable(false)
                    end
                else
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                end
            end, {
                nargs = "?",
                complete = function()
                    return { "on", "off" }
                end
            })
        end,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
        group = augroup,
        callback = function(opts)
            for mapping, mode in pairs {
                ["<space>a"] = {"n", "v"},
                ["gr"]  = "n",
                ["gd"]  = "n",
                ["gi"]  = "n",
                ["<space>rn"]  = "n",
            } do
                utils.lunmap(opts.buf, mode, mapping)
            end

            vim.api.nvim_buf_del_user_command(opts.buf, "InlayHint")
        end
    })

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
            border = "rounded",
        }
    )
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
            border = "rounded"
        }
    )

    local signs = {
        "DiagnosticSignError",
        "DiagnosticSignWarn",
        "DiagnosticSignInfo",
        "DiagnosticSignHint",
    }
    for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign, { texthl = sign, text = "", numhl = sign})
    end

    vim.diagnostic.config {
        float = {
            border = "rounded",
        },
        virtual_text = {
            prefix = "!",
        }
    }

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
            "clangd", "--enable-config", "--background-index"
        },
        on_attach = function()
            -- cycle between definition and implementation files, who cares about select mode lol
            utils.lmap(vim.api.nvim_get_current_buf(), "n", "gH", "<cmd>ClangdSwitchSourceHeader<CR>")
        end
    }
    lspconfig.asm_lsp.setup {
        capabilities = capabilities,
        root_dir = function(path)
            return vim.fs.root(path, ".git")
        end
    }

    -- for some reason it likes to crash with the capabilities
    lspconfig.marksman.setup {

    }
    -- dont need anything special from those *yet*
    for _, lsp in pairs({ "bashls", "ts_ls", "html", "jedi_language_server", "ruff_lsp", "taplo" }) do
        lspconfig[lsp].setup {
            capabilities = capabilities
        }
    end
end

return M
