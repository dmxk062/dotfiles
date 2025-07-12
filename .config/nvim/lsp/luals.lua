---@type vim.lsp.Config
return {
    filetypes = { "lua" },
    cmd = { "lua-language-server" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", ".git" },
    settings = {
        Lua = {
            semantic = {
                -- Luadoc highlighting is much better handled by treesitter
                -- e.g. <.> between elements of an object chain
                annotation = false
            }
        }
    },
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
        if not vim.g.is_neovim and
            not is_in_rtp
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

        require("config.lsp").add_setting(client, "Lua", {
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
