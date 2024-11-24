local M = {
    "stevearc/oil.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "refractalize/oil-git-status.nvim"
    },
}

local perms_hlgroups = {
    ["-"] = "OilNoPerm",
    ["r"] = "OilRead",
    ["w"] = "OilWrite",
    ["x"] = "OilExec",
    ["T"] = "OilSticky",
    ["t"] = "OilSticky",
    ["s"] = "OilSetuid",
}

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
    time = {
        "mtime",
        highlight = function(str)
            local parsed_time = vim.fn.strptime("%H:%M %d-%m-%y", str)
            local cur_time = os.time()
            local diff = cur_time - parsed_time

            if diff < (3600) then
                return "OilTimeLastHour"
            elseif diff < (86400) then
                return "OilTimeLastDay"
            elseif diff < (604800) then
                return "OilTimeLastWeek"
            elseif diff < (2592000) then
                return "OilTimeLastMonth"
            elseif diff < (22896000) then
                return "OilTimeLastYear"
            else
                return "OilTimeSuperOld" -- older than that
            end
        end,
        format = "%H:%M %d-%m-%y"
    },
    size = {
        "size",
        highlight = function(str)
            local suffixes = {
                k = 1024,
                M = 1048576,
                G = 1073741824,
            }
            local factor = suffixes[str:sub(-1, -1)] or 1
            local size = factor * tonumber(str:match("^%d+"))

            if size == 0 then
                return "OilSizeNone"
            elseif size < 4096 then
                return "OilSizeSmall"
            elseif size < 4194304 then
                return "OilSizeMedium"
            elseif size < 134217728 then
                return "OilSizeLarge"
            else
                return "OilSizeHuge"
            end
        end
    }
}

local function open_cmd(cmd)
    require("oil.actions").open_cmdline.callback()
    vim.api.nvim_input(cmd .. " ")
end

local function goto_dir(path)
    require("oil").open(vim.fn.expand(path))
end

local function open_cd()
    vim.api.nvim_input("<ESC>:Oil ")
end

local function goto_git_ancestor()
    local path = require("oil").get_current_dir()
    if not path then
        return
    end

    local git_ancestor = vim.fs.root(path, ".git")

    -- avoid flicker
    if git_ancestor == path or git_ancestor .. "/" == path then
        return
    end

    if git_ancestor then
        require("oil").open(git_ancestor)
    else
        vim.notify("oil: Not in a git repo", vim.log.levels.WARN)
    end
end

local function open_external()
    local entry = require("oil").get_cursor_entry()
    local dir   = require("oil").get_current_dir()
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
        local uri = "sftp://" .. addr .. remote_path .. require("oil").get_cursor_entry().name
        vim.ui.open(uri)
    else
        vim.ui.open(dir .. "/" .. entry.name)
    end
end

local function open_dir_shell(type, where)
    require("utils").kitty_shell_in(require("oil").get_current_dir() or vim.api.nvim_buf_get_name(0), type, where)
end


local sort = {
    { "type", "asc" },
    { "name", "asc" },
}

local sort_types = {
    size = {
        { "size", "desc" },
        { "name", "asc" }
    },
    mtime = {
        { "mtime", "desc" },
        { "name",  "asc" }
    },
    default = {
        { "type", "asc" },
        { "name", "asc" }
    }
}

local function set_sort(action)
    if action == "invert" then
        sort[1][2] = (sort[1][2] == "asc" and "desc" or "asc")
    else
        sort = sort_types[action]
    end

    require("oil").set_sort(sort)
end

local function get_perm_string(mode)
    local perms = {
        "r", "w", "x",
        "r", "w", "x",
        "r", "w", "x",
    }

    local res = ""
    for i = 1, 9 do
        if bit.band(mode, bit.lshift(1, 9 - i)) ~= 0 then
            res = res .. perms[i]
        else
            res = res .. "-"
        end
    end

    return res
end

local extension_highlights = {
    ["a"]       = "Bin",
    ["c"]       = "Source",
    ["cfg"]     = "Config",
    ["conf"]    = "Config",
    ["cpp"]     = "Source",
    ["css"]     = "Style",
    ["desktop"] = "Config",
    ["gz"]      = "Archive",
    ["h"]       = "Code",
    ["html"]    = "Markup",
    ["ini"]     = "Config",
    ["jar"]     = "Archive",
    ["json"]    = "Markup",
    ["log"]     = "Info",
    ["lua"]     = "Source",
    ["md"]      = "Text",
    ["mk"]      = "Build",
    ["o"]       = "Bin",
    ["py"]      = "Script",
    ["pyc"]     = "Bin",
    ["rc"]      = "Config",
    ["scss"]    = "Style",
    ["sh"]      = "Script",
    ["so"]      = "Bin",
    ["tar"]     = "Archive",
    ["tex"]     = "Markup",
    ["toml"]    = "Config",
    ["txt"]     = "Text",
    ["xhtml"]   = "Markup",
    ["xml"]     = "Markup",
    ["xz"]      = "Archive",
    ["yaml"]    = "Config",
    ["zip"]     = "Archive",
}

-- case insensitive
local name_highlights = {
    [".clang-format"] = "Meta",
    [".clangd"]       = "Meta",
    [".config/"]      = "Config",
    [".git/"]         = "Meta",
    [".gitconfig"]    = "Meta",
    [".gitignore"]    = "Meta",
    ["license"]       = "Readme",
    ["license.md"]    = "Readme",
    ["license.txt"]   = "Readme",
    ["makefile"]      = "Build",
    ["readme"]        = "Readme",
    ["readme.md"]     = "Readme",
    ["readme.txt"]    = "Readme",
    ["todo.md"]       = "Readme",
}

M.opts = {
    default_file_explorer = true,
    win_options = {
        cursorlineopt = "line,number",
        signcolumn    = "auto"
    },
    buf_options = {
        buflisted = true
    },
    columns = {
        -- oil_columns.icon,
        -- oil_columns.size,
        oil_columns.time,
        oil_columns.permissions,
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
    watch_for_changes = true,

    view_options = {
        -- always show .. to go up so gg<cr> works
        is_hidden_file = function(name, bufnr)
            return name:sub(1, 1) == "." and not (name:sub(2, 2) == ".")
        end,

        is_always_hidden = function(name, bufnr)
            return name == "."
        end,
        natural_order = true,
        sort = sort,
        highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
            -- fixed names take priority
            local name = entry.name:lower() .. (entry.type == "directory" and "/" or "")
            if name_highlights[name] then
                return "Oil" .. name_highlights[name]
            end

            -- dont try to override directories or links, oil handles them well
            if entry.type == "directory" or entry.type == "link" then
                return
            elseif entry.type == "char" then
                return "OilCharDev"
            elseif entry.type == "block" then
                return "OilBlockDev"
            elseif entry.type == "socket" then
                return "OilSocket"
            end

            local mode = entry.meta.stat.mode
            if bit.band(mode, 0x49) ~= 0 then
                return "OilExecutable"
            end


            local ext = entry.name:match("%.(%w+)$")
            if ext and extension_highlights[ext] then
                return "Oil" .. extension_highlights[ext]
            end

            if is_hidden then
                return "OilHidden"
            end

            return "OilFile"
        end
    },

    keymaps = {
        ["!"]         = function() open_cmd("!") end,
        ["<C-space>"] = "actions.refresh",
        ["<CR>"]      = "actions.select",
        ["<S-CR>"]    = "actions.select_tab",
        ["<C-CR>"]    = "actions.select_split",
        ["<M-CR>"]    = "actions.select_vsplit",

        ["es"]        = "actions.select_split",
        ["et"]        = "actions.select_tab",
        ["ev"]        = "actions.select_vsplit",
        ["eo"]        = open_external,
        ["gx"]        = open_external,

        -- goto places
        ["g~"]        = function() goto_dir("~") end,
        ["gr"]        = function() require("oil").open("/") end,
        ["g/"]        = function() require("oil").open("/") end,
        ["gp"]        = "actions.parent",
        ["g.."]       = "actions.parent",

        -- only applies to my machines
        ["gw"]        = function() goto_dir("~/ws") end,
        ["gt"]        = function() goto_dir("~/Tmp") end,

        ["gP"]        = goto_git_ancestor,
        ["gG"]        = goto_git_ancestor,
        ["gz"]        = function() require("telescope").extensions.zoxide.list() end,

        -- toggle hidden
        ["gh"]        = "actions.toggle_hidden",
        ["gH"]        = "actions.toggle_hidden",
        ["g<space>"]  = open_cd,

        ["<space>sw"] = function() open_dir_shell("window") end,
        ["<space>sv"] = function() open_dir_shell("window", "vsplit") end,
        ["<space>ss"] = function() open_dir_shell("window", "hsplit") end,
        ["<space>sW"] = function() open_dir_shell("os-window") end,
        ["<space>so"] = function() open_dir_shell("overlay") end,
        ["<space>st"] = function() open_dir_shell("tab") end,

        ["g=s"]       = function() set_sort("size") end,
        ["g=t"]       = function() set_sort("mtime") end,
        ["g=i"]       = function() set_sort("invert") end,
        ["g=d"]       = function() set_sort("default") end,

        -- only close oil buffer if it is the last one
        ["q"]         = function()
            if not (#vim.api.nvim_list_wins() > 1) then
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.bo[buf].filetype ~= "oil" then
                        vim.api.nvim_win_set_buf(0, buf)
                        return
                    end
                end
            end
            vim.cmd("quit")
        end,
    },
}

M.config = function(_, opts)
    local map = require("utils").map
    require("oil").setup(opts)

    -- change directory if not ssh, only for current window
    vim.api.nvim_create_autocmd("User", {
        pattern  = "OilEnter",
        callback = function(bufnr)
            local dir = require("oil").get_current_dir()
            if dir then
                vim.cmd.lcd(dir)
            end
        end
    })

    local prefix = "<space>f"
    map("n", prefix .. "f", require("oil").open)
    map("n", prefix .. "F", require("oil").open_float)

    map("n", prefix .. "t", function()
        vim.api.nvim_command("tabnew")
        require("oil").open()
    end)
    map("n", prefix .. "s", function()
        vim.api.nvim_command("split")
        require("oil").open()
    end)
    map("n", prefix .. "v", function()
        vim.api.nvim_command("vsplit")
        require("oil").open()
    end)

    require("oil-git-status").setup {}
end

return M
