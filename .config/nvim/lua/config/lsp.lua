--[[ LSP-Configuration
Set up LSPs
]]

local utils = require("config.utils")

-- Callbacks & Mappings {{{
local function lsp_map(buf)
    local map = utils.local_mapper(buf, { group = true })
    map({ "n", "v" }, "<space>a", vim.lsp.buf.code_action)

    -- renaming: three ways
    -- the classic way that uses vim.ui.input, useful if more than one edit needs to be made
    map("n", "<space>r", vim.lsp.buf.rename)

    -- using a vim operator in visual mode
    -- this allows things the default rename behavior just makes harder
    -- e.g. you can just <space>rgU to capitalize a symbol
    map("n", "<space>gr", function()
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

    -- fully replace the symbol
    map("n", "<space>C", "<space>grc", { remap = true })


    -- list lsp things and use telescope to disambiguate
    map("n", "gd", function() require("telescope.builtin").lsp_definitions() end)
    map("n", "gr", function() require("telescope.builtin").lsp_references() end)
    map("n", "gi", function() require("telescope.builtin").lsp_implementations() end)

    -- go to the thing in a split and use the loclist to disambiguate instead of telescope
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

local on_lsp_attached = function(ev)
    local buf = ev.buf

    lsp_map(buf)

    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- make the 'path' match the one of the language server
    if client and client.workspace_folders then
        vim.opt_local.path = vim.tbl_map(function(t)
            return vim.uri_to_fname(t.uri) .. "/**"
        end, client.workspace_folders)

        vim.fn.chdir(vim.uri_to_fname(client.workspace_folders[1].uri))
    end

    vim.api.nvim_buf_create_user_command(buf, "InlayHint", function(args)
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

local on_lsp_detached = function(ev)
    -- reset the 'path'
    vim.opt_local.path = vim.opt_global.path

    pcall(utils.unmap_group, ev.buf)
    pcall(vim.api.nvim_buf_del_user_command, ev.buf, "InlayHint")
end

utils.autogroup("config.lsp", {
    LspAttach = on_lsp_attached,
    LspDetach = on_lsp_detached,
    LspProgress = function(ev)
        local data = ev.data
        local client = vim.lsp.get_client_by_id(data.client_id)
        if not client then
            return
        end

        local value = data.params.value

        local message = {
            { client.name, "Identifier" },
            { ": ",        "Delimiter" },
        }

        if value.kind == "end" then
            table.insert(message, { "Finished " })
            table.insert(message, { value.title })
        else
            table.insert(message, { value.title })
            table.insert(message, { (" %02d%%"):format(value.percentage), "Number" })
        end

        vim.api.nvim_echo(message, false, {})
    end,
})
-- }}}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

---@param client vim.lsp.Client
local add_setting = function(client, k, v)
    if not client.settings then
        client.settings = {}
    end
    if not client.settings[k] then
        client.settings[k] = {}
    end

    client.settings[k] = v
end

-- load schemastore on launch only
local lazy_schemastore = function(type)
    ---@param client vim.lsp.Client
    return function(client)
        ---@diagnostic disable-next-line: undefined-field
        add_setting(client, "json", { schemas = require("schemastore")[type].schemas() })
    end
end

---@type table<string, vim.lsp.Config>
local L = setmetatable({}, {
    __newindex = function(t, name, cfg)
        if not cfg.name then
            cfg.name = name
        end

        if cfg.capabilities == false then
            cfg.capabilities = nil
        else
            cfg.capabilities = capabilities
        end

        vim.lsp.config[name] = cfg
        rawset(t, name, true)
    end
})

--- Configs {{{
L.jsonls = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    init_options = {
        provideFormatter = true
    },
    root_markers = { ".git" },
    on_init = lazy_schemastore("json")
}

L.yamlls = {
    filetypes = { "yaml" },
    cmd = { "yaml-language-server", "--stdio" },
    root_markers = { ".git" },
    settings = { redhat = { telemetry = { enabled = false } } },
    on_init = lazy_schemastore("yaml"),
}

L.luals = {
    filetypes = { "lua" },
    cmd = { "lua-language-server" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", ".git" },
    on_init = function(client)
        if not client.workspace_folders then
            return
        end

        local path = client.workspace_folders[1].name

        local is_in_rtp = false
        for _, elem in pairs(vim.opt.runtimepath:get()) do
            if vim.startswith(path, elem) then
                is_in_rtp = true
                break
            end
        end
        if not is_in_rtp
            and not vim.startswith(path, vim.fn.stdpath("data"))
            and not vim.startswith(path, vim.fn.expand("~/ws/scratch")) then
            return
        end

        -- load nvim-specific libraries only for config
        local libpaths = {
            vim.env.VIMRUNTIME,   -- runtime files
            "${3rd}/luv/library", -- vim.uv
            vim.fn.stdpath("config") .. "/lua"
        }

        -- load lazy plugins for those that do use lua
        for _, plug in pairs(require("lazy").plugins()) do
            local dir = plug.dir .. "/lua"
            if vim.uv.fs_stat(dir) then
                table.insert(libpaths, dir)
            end
        end

        add_setting(client, "Lua", {
            runtime = {
                -- should hold true for any decent system
                version = "LuaJIT",
                -- prefer plugins over specs
                path = { "?/init.lua", "?.lua" },
                strictPath = true
            },
            workspace = {
                checkThirdParty = false,
                library = libpaths,
            }
        })
    end
}

L.clangd = {
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    cmd = { "clangd" },
    root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "Makefile", ".git" },
    on_attach = function(client, buf)
        local map = utils.local_mapper(buf, { group = true })

        -- goto header
        map("n", "gh", function()
            local params = vim.lsp.util.make_text_document_params(buf)
            client:request("textDocument/switchSourceHeader", params, function(err, res)
                if err then
                    vim.notify(tostring(err), vim.log.levels.ERROR)
                    return
                end

                if not res then
                    vim.notify("Clangd: Could not determine corresponding header/implementation file")
                    return
                end

                vim.cmd.edit(vim.uri_to_fname(res))
            end)
        end)
    end
}

L.asm_lsp = {
    filetypes = { "asm", "vmasm" },
    cmd = { "asm-lsp" },
    root_markers = { ".asm-lsp.toml", ".git" },
}

L.bashls = {
    filetypes = { "bash", "sh" },
    cmd = { "bash-language-server", "start" },
    root_markers = { ".git" },
}

L.ts_ls = {
    filetypes = { "javascript", "typescript" },
    cmd = { "typescript-language-server", "--stdio" },
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
}

L.html_ls = {
    filetypes = { "html" },
    cmd = { "vscode-html-language-server", "--stdio" },
    init_options = {
        provideFormatter = true,
        embeddedLanguages = { css = true, javascript = true },
        configurationSection = { "html", "css", "javascript" },
    }
}

L.jedi_ls = {
    filetypes = { "python" },
    cmd = { "jedi-language-server" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
}

L.ruff = {
    filetypes = { "python" },
    cmd = { "ruff", "server" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml" }
}

L.taplo = {
    filetypes = { "toml" },
    cmd = { "taplo", "lsp", "stdio" },
    root_markers = { ".git" },
}

L.marksman = {
    filetypes = { "markdown" },
    cmd = { "marksman", "server" },
    root_markers = { ".marksman.toml", ".git" },
}

L.tinymist = {
    filetypes = { "typst" },
    cmd = { "tinymist" },
    root_markers = { ".git" },
}
-- }}}

vim.lsp.enable(vim.tbl_keys(L))
