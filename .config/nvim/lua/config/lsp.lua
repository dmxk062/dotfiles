--[[ LSP-Configuration
Set up LSPs
]]

local M = {}

local api = vim.api
local utils = require("config.utils")
local lsp = vim.lsp

local rename_visually = function()
    local old_name = vim.fn.expand("<cword>")
    vim.cmd("normal! viw")
    api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
        buffer = api.nvim_get_current_buf(),
        once = true,
        callback = function()
            local new_name = vim.fn.expand("<cword>")
            if new_name == old_name then
                return
            end

            vim.cmd.undo()
            lsp.buf.rename(new_name)
        end
    })
end

-- Callbacks & Mappings {{{
---@type [nvim_mode, string, function|string, vim.keymap.set.Opts?][]
local lsp_mappings = {
    {
        utils.mode_action, "<space>a",
        lsp.buf.code_action,
        { desc = "LSP: Code action" }
    },

    -- renaming: two ways
    -- the classic way that uses vim.ui.input, useful if more than one edit needs to be made
    {
        "n", "<space>r",
        lsp.buf.rename,
        { desc = "LSP: Rename symbol" }
    },

    -- using a vim operator in visual mode
    -- this allows things the default rename behavior just makes harder
    -- e.g. we can just <space>RU to capitalize a symbol
    -- or <space>R"xgs to replace the name of a symbol with a register's content
    {
        "n", "<space>R",
        rename_visually,
        { desc = "LSP: Rename symbol visually" }
    },

    -- Select using telescope
    {
        "n", "gd",
        function() require("telescope.builtin").lsp_definitions() end,
        { desc = "LSP: Select Definitions" }
    },
    {
        "n", "gr",
        function() require("telescope.builtin").lsp_references() end,
        { desc = "LSP: Select References" }
    },
    {
        "n", "gi",
        function() require("telescope.builtin").lsp_implementations() end,
        { desc = "LSP: Select Implementations" }
    },

    -- List in the location list
    {
        "n", "gld",
        function() lsp.buf.definition { loclist = true } end,
        { desc = "LSP: List Definitions" }
    },
    {
        "n", "glr",
        function() lsp.buf.references(nil, { loclist = true }) end,
        { desc = "LSP: List References" }
    },
    {
        "n", "gli",
        function() lsp.buf.implementation { loclist = true } end,
        { desc = "LSP: List Implementations" }
    },

    -- Open in a split
    {
        "n", "<C-w>gd",
        function()
            utils.open_window_smart(0, { enter = true })
            lsp.buf.definition { reuse_win = false, loclist = true }
            vim.cmd.normal("zz")
        end,
        { desc = "LSP: (other Window) Definitions" }
    },
    {
        "n", "<C-w>gr",
        function()
            utils.open_window_smart(0, { enter = true })
            lsp.buf.references(nil, { loclist = true })
            vim.cmd.normal("zz")
        end,
        { desc = "LSP: (other Window) References" }
    },
    {
        "n", "<C-w>gi",
        function()
            utils.open_window_smart(0, { enter = true })
            lsp.buf.implementation { reuse_win = false, loclist = true }
            vim.cmd.normal("zz")
        end,
        { desc = "LSP: (other Window) Implementations" }
    },
}

---@param args vim.api.keyset.create_user_command.command_args
local inlay_hint_command = function(args)
    local cmd = args.fargs[1]
    if cmd then
        if cmd == "on" then
            lsp.inlay_hint.enable(true)
        elseif cmd == "off" then
            lsp.inlay_hint.enable(false)
        end
    else
        lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled())
    end
end

---@param args vim.api.keyset.create_user_command.command_args
local sdo_command = function(args)
    lsp.buf.references(nil, {
        on_list = function(res)
            for _, elem in ipairs(res.items) do
                local buf = vim.fn.bufadd(elem.filename)
                vim.fn.bufload(buf)
                api.nvim_buf_call(buf, function()
                    api.nvim_win_set_cursor(0, { elem.lnum, elem.col - 1 })
                    vim.cmd(args.args)
                end)
                if vim.bo[buf].modified then
                    vim.bo[buf].buflisted = true
                end
            end
        end
    })
end

---@type table<string, [fun(args: vim.api.keyset.create_user_command.command_args), vim.api.keyset.user_command]>
local lsp_commands = {
    InlayHint = {
        inlay_hint_command,
        {
            nargs = "?",
            desc = "LSP: Set Inlay-Hints",
            complete = function()
                return { "on", "off" }
            end
        }
    },
    Sdo = {
        sdo_command,
        {
            desc = "LSP: Execute CMD for every occurence of the symbol",
            complete = "command",
            nargs = "+",
        }
    }
}

---Add a mapping for when LSP is active
---@param mode nvim_mode
---@param keys string
---@param action string|function
---@param opts vim.keymap.set.Opts?
M.lsp_map = function(mode, keys, action, opts)
    table.insert(lsp_mappings, { mode, keys, action, opts })
end

local on_lsp_attached = function(ev)
    local buf = ev.buf

    local map = utils.local_mapper(buf, { group = true })
    for _, action in ipairs(lsp_mappings) do
        map(action[1], action[2], action[3], action[4])
    end

    local client = lsp.get_client_by_id(ev.data.client_id)

    -- make the 'path' match the one of the language server
    -- NOTE: don't replace the whole 'path', since that might be set by ftplugins
    if client and client.workspace_folders then
        local workspace_path = vim.tbl_map(function(t)
            return vim.uri_to_fname(t.uri) .. "/**"
        end, client.workspace_folders)

        -- remove all the basic wildcards
        vim.opt_local.path:remove { "*", "../*" }
        vim.opt_local.path:prepend(workspace_path)

        vim.fn.chdir(vim.uri_to_fname(client.workspace_folders[1].uri))
    end

    for cmd, action in pairs(lsp_commands) do
        api.nvim_buf_create_user_command(buf, cmd, action[1], action[2])
    end

    require("workspace-diagnostics").populate_workspace_diagnostics(client, buf)
end

local on_lsp_detached = function(ev)
    -- reset the 'path'
    vim.opt_local.path = vim.opt_global.path

    pcall(utils.unmap_group, ev.buf)
    for cmd, _ in pairs(lsp_commands) do
        pcall(api.nvim_buf_del_user_command, ev.buf, cmd)
    end
end

utils.autogroup("config.lsp", {
    LspAttach = on_lsp_attached,
    LspDetach = on_lsp_detached,
    LspProgress = function(ev)
        local data = ev.data
        local client = lsp.get_client_by_id(data.client_id)
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
        elseif value.percentage then
            table.insert(message, { value.title })
            table.insert(message, { (" %02d%%"):format(value.percentage), "Number" })
        end

        api.nvim_echo(message, false, {})
    end,
})
-- }}}

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

        lsp.config[name] = cfg
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
            and not vim.startswith(path, vim.fn.stdpath("data")) then
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
            local params = lsp.util.make_text_document_params(buf)
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

L.gopls = {
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    cmd = { "gopls" },
    root_markers = { "go.mod", "go.work", ".git" },
}
-- }}}

lsp.enable(vim.tbl_keys(L))

return M
