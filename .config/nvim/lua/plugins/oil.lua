return {
    "stevearc/oil.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "refractalize/oil-git-status.nvim"
    },
    config = function()
        local actions = require("oil.actions")
        local lspconfig = require("lspconfig.util")
        local api = require("oil")
        local utils = require("utils")


        local perms_hlgroups = {
            ['-'] = "OilNoPerm",
            ['r'] = "OilRead",
            ['w'] = "OilWrite",
            ['x'] = "OilExec",
            ['t'] = "OilSticky",
            ['s'] = "OilSetuid",
        }


        local function open_chmod()
            actions.open_cmdline.callback()
            vim.api.nvim_input("!chmod ")
        end

        local oil_columns = {
            icon = {
                "icon",
                default_file = "󰈔",
                directory = "",
            },
            permissions = {
                "permissions",
                highlight = function(str)
                    local hls = {}
                    for i = 1, #str do
                        table.insert(hls, { perms_hlgroups[str:sub(i, i)], i - 1, i })
                    end
                    return hls
                end,
            },
        }

        api.setup({
            default_file_explorer = true,


            win_options = {
                cursorlineopt = "line,number",
                signcolumn    = "auto"
            },
            columns = {
                oil_columns.icon,
                oil_columns.permissions
            },
            constrain_cursor = "editable",
            skip_confirm_for_simple_edits = true,

            float = {
                padding = 16,
                max_width = 80,
                max_height = 40,

            },
            preview = {
                max_width = 0.6,
                min_width = 0.4,
                max_height = 0.8,
                min_height = 0.6,

            },
            use_default_keymaps = true,
            cleanup_delay_ms = 5000,
            extra_scp_args = { "-O" }, -- use scp instead of sftp
            experimental_watch_for_changes = true,

            view_options = {
                is_hidden_file = function(name, bufnr)
                    return vim.startswith(name, '.') and not (name:sub(2, 2) == ".")
                end,

                is_always_hidden = function(name, bufnr)
                    return name == "."
                end,
                natural_order = true,
            },

            keymaps = {
                ["!"] = function()
                    actions.open_cmdline.callback()
                    vim.api.nvim_input("! ")
                end,
                ["<C-space>"] = actions.refresh,
                ["<CR>"] = actions.select,
                ["<S-CR>"] = actions.select_tab,
                ["<C-CR>"] = actions.select_split,
                ["<M-CR>"] = actions.select_vsplit,


            },
        })

        -- automatically cd the whole nvim
        vim.api.nvim_create_autocmd("User", {
            pattern  = "OilEnter",
            callback = function(bufnr)
                -- change directory if not ssh
                if api.get_current_dir() then
                    actions.cd.callback()
                end
            end
        })

        -- all the actions for the keybinds
        local function goto_dir(path)
            api.open(vim.fn.expand(path))
        end

        local function open_cd()
            vim.api.nvim_input("<ESC>:Oil ")
        end

        local function goto_git_ancestor()
            api.open(lspconfig.find_git_ancestor(api.get_current_dir()))
        end

        local function toggle_git_shown()
            if vim.wo.signcolumn == "no" then
                vim.wo.signcolumn = "auto"
            else
                vim.wo.signcolumn = "no"
            end
        end

        local function open_external()
            local entry = api.get_cursor_entry()
            local dir   = api.get_current_dir()
            if not dir then
                -- ssh, we hope that the application uses gio or whatever and can use sftp:// uris
                -- if that doesnt work, try
                -- `xdg-mime default <application>.desktop x-scheme-handler/sftp`
                -- where application is an app that can talk sftp
                -- org.gnome.Nautilus works for instance
                -- TODO: write some hacky handler myself that uses gio to then open that
                local bufname = vim.api.nvim_buf_get_name(0)
                local addr = bufname:match("//(.-)/")
                local remote_path = bufname:match("//.-(/.*)"):sub(2, -1)
                local uri = "sftp://" .. addr .. remote_path .. api.get_cursor_entry().name
                vim.fn.jobstart("xdg-open '" .. uri .. "'")
            else
                vim.fn.jobstart("xdg-open '" .. dir .. "/" .. entry.name .. "'")
            end
        end

        local function open_dir_shell(type, where)
            utils.kitty_shell_in(api.get_current_dir() or vim.api.nvim_buf_get_name(0), type, where)
        end


        -- TODO: use this for mappings instead
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "oil",

            callback = function()
                local normal_mappings = {
                    -- edit in <thing>
                    { "es",  actions.select_split.callback },
                    { "et",  actions.select_tab.callback },
                    { "ev",  actions.select_vsplit.callback },

                    { "eo",  open_external },

                    -- edit permissions
                    { "ep",  open_chmod },

                    -- goto places
                    { "g~",  function() goto_dir("~") end },

                    { "gr",  function() api.open("/") end },
                    { "g/",  function() api.open("/") end },

                    { "gp",  actions.parent.callback },
                    { "g..", actions.parent.callback },

                    -- only applies to my machines
                    { "gw",  function() goto_dir("~/ws") end },
                    { "gt",  function() goto_dir("~/Tmp") end },

                    { "gP",  goto_git_ancestor },

                    -- toggle hidden
                    { "gh",  actions.toggle_hidden.callback },
                    { "gH",  actions.toggle_hidden.callback },
                    { "gs",  toggle_git_shown },


                    { "cd",  open_cd },

                    { " sw", function() open_dir_shell("window") end },
                    { " sv", function() open_dir_shell("window", "vsplit") end },
                    { " ss", function() open_dir_shell("window", "hsplit") end },
                    { " sW", function() open_dir_shell("os-window") end },
                    { " so", function() open_dir_shell("overlay") end },
                    { " st", function() open_dir_shell("tab") end },
                }
                for _, map in ipairs(normal_mappings) do
                    utils.lmap(0, "n", map[1], map[2])
                end
            end,
        })

        local prefix = "<space>f"
        utils.map("n", prefix .. "F", api.open_float)
        utils.map("n", prefix .. "f", api.open)

        utils.map("n", prefix .. "t", function()
            vim.api.nvim_command("tabnew")
            api.open()
        end)
        utils.map("n", prefix .. "s", function()
            vim.api.nvim_command("split")
            api.open()
        end)
        utils.map("n", prefix .. "v", function()
            vim.api.nvim_command("vsplit")
            api.open()
        end)


        local function oil_cmp_get_pwd()
            -- return the local pwd if ssh
            return api.get_current_dir() or vim.fn.getcwd()
        end

        local cmp = require("cmp")
        cmp.setup.filetype("oil", {
            sources = cmp.config.sources({
                {
                    name = 'path',
                    option = {
                        get_cwd = oil_cmp_get_pwd
                    }
                },
                { name = 'luasnip' },
                { name = 'buffer' },
                { name = 'nvim_lsp' },
            })
        })

        require("oil-git-status").setup({})
    end
}
