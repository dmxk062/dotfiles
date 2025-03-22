-- Spec {{{
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
                    automatic_installation = false,
                    ensure_installed = {
                        "ruff",
                        "asm_lsp",
                        "typos_lsp"
                    }
                }
            end,
            cmd = { "Mason", "MasonInstall", "MasonLog", "MasonUninstall", "MasonUninstallAll", "MasonUpdate" },
            dependencies = {
                "williamboman/mason-lspconfig.nvim",
            },
        },
    },
    event = { "BufNewFile", "BufReadPost" }
}
-- }}}

-- Keymapping {{{
local utils = require("config.utils")
local lsp_map = function(buf)
    local map = utils.local_mapper(buf, { group = true })
    map({ "n", "v" }, "<space>a", vim.lsp.buf.code_action)

    -- rename using a vim operator in visual mode
    -- this allows things the default rename behavior just makes harder
    -- e.g. you can just <space>rgU to capitalize a symbol
    map("n", "<space>r", function()
        local old_name = vim.fn.expand("<cword>")
        vim.cmd("normal! viw")
        vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
            buffer = vim.api.nvim_get_current_buf(),
            once = true,
            callback = function()
                local new_name = vim.fn.expand("<cword>")

                if new_name == old_name then
                    return
                end

                vim.cmd.undo()
                vim.lsp.buf.rename(new_name)
            end
        })
    end)
    map("n", "<space>c", "<space>rc", { remap = true })

    -- keep the classic rename around, useful for symbols that aren't exactly a <cword>
    map("n", "<space>R", vim.lsp.buf.rename)

    -- list lsp things and use telescope to disambiguate
    map("n", "gd", function() require("telescope.builtin").lsp_definitions() end)
    map("n", "gr", function() require("telescope.builtin").lsp_references() end)
    map("n", "gi", function() require("telescope.builtin").lsp_implementations() end)

    -- go to the thing in a split and use the qflist to disambiguate instead of telescope
    map("n", "<C-w>gd", function()
        utils.open_window_smart(0, { enter = true })
        vim.lsp.buf.definition { reuse_win = false, loclist = true }
        vim.cmd.normal("zz")
    end)
    map("n", "<C-w>gr", function()
        utils.open_window_smart(0, { enter = true })
        vim.lsp.buf.references(nil, { loclist = true })
        vim.cmd.normal("zz")
    end)
    map("n", "<C-w>gi", function()
        utils.open_window_smart(0, { enter = true })
        vim.lsp.buf.implementation { reuse_win = false, loclist = true }
        vim.cmd.normal("zz")
    end)
end

local on_attach = function(ev)
    lsp_map(ev.buf)
    vim.api.nvim_buf_create_user_command(ev.buf, "InlayHint", function(args)
        local cmd = args.fargs[1]
        if cmd then
            if cmd == "on" then
                vim.lsp.inlay_hint.enable(true)
            elseif cmd == "off" then
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
end

local on_detach = function(ev)
    utils.unmap_group(ev.buf)
    vim.api.nvim_buf_del_user_command(ev.buf, "InlayHint")
end
-- }}}

-- Configs {{{
local L = {}

-- lazy load schemastore schemas
local lazy_schemastore = function(type)
    return function(client)
        client.config.settings[type].schemas = require("schemastore")[type].schemas()
    end
end

L.jsonls = {
    capabilities = true,
    settings = {
        json = {
            validate = { enable = true },
        },
    },
    on_init = lazy_schemastore("json")
}

L.yamlls = {
    capabilities = true,
    settings = {
        yaml = {
            schemaStore = {
                enable = false,
                url = "",
            }
        }
    },
    on_init = lazy_schemastore("yaml")
}

L.lua_ls = {
    capabilities = true,
    settings = {
        Lua = {}
    }
}
L.lua_ls.on_init = function(client)
    local path = client.workspace_folders[1].name

    local is_in_rtp = false
    for _, elem in pairs(vim.opt.runtimepath:get()) do
        if vim.startswith(path, elem) then
            is_in_rtp = true
            break
        end
    end
    if not is_in_rtp and not vim.startswith(path, vim.fn.stdpath("data")) then
        return
    end

    local libpaths = {
        vim.env.VIMRUNTIME,   -- runtime files
        "${3rd}/luv/library", -- vim.uv
    }

    -- load lazy plugins for those that do use lua
    for _, plug in pairs(require("lazy").plugins()) do
        local dir = plug.dir .. "/lua"
        if vim.uv.fs_stat(dir) then
            table.insert(libpaths, dir)
        end
    end

    -- put config files last so plugin specs don't conflict with plugins
    table.insert(libpaths, vim.fn.stdpath("config") .. "/lua")

    -- load nvim-specific libraries only for config
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
            version = "LuaJIT"
        },
        workspace = {
            checkThirdParty = false,
            library = libpaths,
        }
    })
end

L.clangd = {
    capabilities = true,
    cmd = {
        "clangd", "--enable-config", "--background-index"
    },
    on_attach = function()
        local map = utils.local_mapper(vim.api.nvim_get_current_buf(), { group = true })
        map("n", "gH", "<cmd>ClangdSwitchSourceHeader<CR>")
    end
}

L.asm_lsp = {
    capabilities = true,
    root_dir = function(path)
        return vim.fs.root(path, ".git")
    end
}

L.marksman = {} -- crashes with my capabilities for some reasons

L.hls = {
    capabilities = true,
    filetypes = { 'haskell', 'lhaskell', 'cabal' },
}

for _, lsp in pairs({ "bashls", "ts_ls", "html", "jedi_language_server", "ruff", "taplo" }) do
    L[lsp] = { capabilities = true }
end
-- }}}

-- Config Function {{{
M.config = function()
    local lspconfig = require("lspconfig")

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
    }

    -- rounded corners for everything
    require("lspconfig.ui.windows").default_options = {
        border = "rounded"
    }
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
    vim.diagnostic.config {
        float = {
            border = "rounded",
        },
        virtual_text = {
            prefix = "!",
        }
    }

    local augroup = utils.autogroup("config.lspconfig", {
        LspAttach = on_attach,
        LspDetach = on_detach,
    })

    -- remove sign text
    local signs = {
        "DiagnosticSignError",
        "DiagnosticSignHint",
        "DiagnosticSignInfo",
        "DiagnosticSignWarn",
    }
    for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign, { texthl = sign, text = "", numhl = sign })
    end

    for lsp, config in pairs(L) do
        if config.capabilities == true then
            config.capabilities = capabilities
        end
        lspconfig[lsp].setup(config)
    end
end
-- }}}

return M
