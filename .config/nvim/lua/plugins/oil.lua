---@type LazySpec
local M = {
    "stevearc/oil.nvim",
}
local utils = require("config.utils")

--[[ Why Oil? {{{
Because it's the best file editor :3
Edits to the filesystem work the same as text files
Additionally, it's really fast and rock solid
}}} ]]

-- Columns {{{
local perms_hlgroups = {
    ["-"] = "OilNoPerm",
    ["r"] = "OilRead",
    ["w"] = "OilWrite",
    ["x"] = "OilExec",
    ["T"] = "OilSticky",
    ["t"] = "OilSticky",
    ["s"] = "OilSetuid",
}

local datefmt = utils.datefmt.long
local highlight_date = function(str)
    local parsed_time = vim.fn.strptime(datefmt, str)
    return utils.highlight_time(parsed_time)
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
    time = {
        "mtime",
        highlight = highlight_date,
        format = datefmt,
    },
    birthtime = {
        "birthtime",
        highlight = highlight_date,
        format = datefmt,
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
            return utils.highlight_size(size)
        end
    }
}

local column_positions = {
    time = 1,
    birthtime = 2,
    size = 3,
    permissions = 4,
}

local enabled_columns = {
    "time",
    nil,
    nil,
    "permissions"
}
-- }}}

-- Custom actions essentially {{{
local function get_entries()
    local oil = require("oil")

    local ret = {}
    local startl, endl = utils.get_range()
    for i = startl, endl do
        local e = oil.get_entry_on_line(0, i)
        if e then
            table.insert(ret, e)
        end
    end

    return ret
end
local function goto_dir(path)
    require("oil").open(vim.fn.expand(path))
end

local function open_cmd(cmd)
    local files = vim.tbl_map(function(e)
        return vim.fn.fnameescape(e.name)
    end, get_entries())

    vim.api.nvim_feedkeys(":", "n")
    vim.schedule(function()
        vim.fn.setcmdline(cmd .. " " .. table.concat(files, " "), #cmd + 1)
    end)
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

    if not git_ancestor then
        vim.notify("oil: Not in a git repo", vim.log.levels.WARN)
        return
    end

    -- avoid flicker
    if git_ancestor == path or git_ancestor .. "/" == path then
        return
    end

    require("oil").open(git_ancestor)
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

local function set_column(col, state)
    enabled_columns[column_positions[col]] = state and col or nil
    require("oil").set_columns(vim.tbl_map(function(c)
        return oil_columns[c]
    end, vim.tbl_values(enabled_columns)))
end

local function default_is_hidden(name, bufnr)
    if name then
        return name:sub(1, 1) == "." and not (name:sub(2, 2) == ".")
    else
        return false
    end
end

local cur_filter_pattern

local function filter_items()
    local function set_filter(filter)
        require("oil").set_is_hidden_file(function(fname, buf)
            -- HACK: prevent dir from being empty
            if fname == ".." then
                return false
            end

            return vim.regex(filter):match_str(fname) == nil
        end)
    end
    vim.ui.input({
        default = cur_filter_pattern,
        prompt = "Filter Regex",
        _ts_lang = "regex",
        -- abuse it to update continuously
        highlight = function(pattern)
            set_filter(pattern)
            return {}
        end
    }, function(reply)
        if not reply or reply == "" then
            require("oil").set_is_hidden_file(default_is_hidden)
        else
            set_filter(reply)
            cur_filter_pattern = reply
        end
    end)
end

--- Calls vim.cmd
---@param command string
local function git_command(command)
    local dir = require("oil").get_current_dir(0)
    if not dir then
        vim.notify("Oil: Cannot run git command on non-local fs", vim.log.levels.WARN)
        return
    end

    local files = vim.tbl_map(function(e)
        return vim.fn.fnameescape(dir .. "/" .. e.name)
    end, get_entries())

    vim.cmd {
        cmd = "Git",
        mods = {
            silent = true,
        },
        args = { command .. " " .. table.concat(files, " ") }
    }
end
-- }}}

-- Options {{{
---@type oil.setupOpts
M.opts = {
    default_file_explorer = true,
    win_options = {
        cursorlineopt = "number",
        signcolumn    = "auto"
    },
    buf_options = {
        buflisted = true
    },
    columns = {
        oil_columns.time,
        oil_columns.permissions,
    },
    constrain_cursor = "editable",
    skip_confirm_for_simple_edits = true,

    float = {
        padding = 8,
        max_width = 80,
        max_height = 40,
    },
    preview = {
        max_width = 0.6,
        min_width = 0.4,
        max_height = 0.8,
        min_height = 0.6,

    },
    use_default_keymaps = false,
    cleanup_delay_ms = 5000,
    extra_scp_args = { "-O" }, -- use scp instead of sftp
    watch_for_changes = true,

    view_options = {
        -- always show .. to go up so gg<cr> works
        is_hidden_file = default_is_hidden,

        is_always_hidden = function(name, bufnr)
            return name == "."
        end,
        natural_order = true,
        sort = sort,
        highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
            return utils.highlight_fname(nil, entry, is_hidden)
        end
    },

    keymaps = {
        ["!"]         = function() open_cmd("!") end,
        ["cm"]        = function() open_cmd("!chmod ") end,
        ["co"]        = function() open_cmd("!chown ") end,
        ["<CR>"]      = "actions.select",
        ["<S-CR>"]    = "actions.select_split",
        ["<C-CR>"]    = "actions.select_vsplit",

        ["es"]        = "actions.select_split",
        ["ev"]        = "actions.select_vsplit",
        ["gx"]        = "actions.open_external",

        -- goto places
        ["g<space>"]  = open_cd,
        ["g~"]        = function() goto_dir("~") end,
        ["gr"]        = function() require("oil").open("/") end,
        ["g/"]        = function() require("oil").open("/") end,
        ["gp"]        = "actions.parent",
        ["g.."]       = "actions.parent",
        ["gP"]        = { goto_git_ancestor, mode = "n" },
        ["gG"]        = { goto_git_ancestor, mode = "n" },
        -- only applies to my machines
        ["gw"]        = function() goto_dir("~/ws") end,
        ["gt"]        = function() goto_dir("~/Tmp") end,

        -- toggle hidden
        ["gh"]        = "actions.toggle_hidden",

        ["gf"]        = filter_items,
        ["=s"]        = function() set_sort("size") end,
        ["=t"]        = function() set_sort("mtime") end,
        ["=i"]        = function() set_sort("invert") end,
        ["=d"]        = function() set_sort("default") end,

        ["+s"]        = function() set_column("size", true) end,
        ["-s"]        = function() set_column("size", false) end,
        ["+p"]        = function() set_column("permissions", true) end,
        ["-p"]        = function() set_column("permissions", false) end,
        ["+t"]        = function() set_column("time", true) end,
        ["-t"]        = function() set_column("time", false) end,
        ["+b"]        = function() set_column("birthtime", true) end,
        ["-b"]        = function() set_column("birthtime", false) end,

        ["+q"]        = "actions.add_to_qflist",

        ["<space>gs"] = function() git_command("add") end,
        ["<space>gU"] = function() git_command("reset") end,
    },
}
-- }}}

M.config = function(_, opts)
    local map = utils.map
    local oil = require("oil")
    oil.setup(opts)

    local git_status = require("config.plugins.oil_git")

    -- change directory if not ssh, only for current window
    utils.user_autogroup("config.oil", {
        OilEnter = function(ev)
            git_status.attach(ev.buf)
            local dir = oil.get_current_dir()
            if dir then
                vim.fn.chdir(dir)
            end
        end
    })

    -- [p]arent, why use <C-p> if k exists
    map("n", "<C-p>", oil.open)

    local prefix = "<space>f"
    map("n", prefix .. "f", oil.open)

    map("n", "<C-'>", function()
        vim.cmd("Split")
        oil.open()
    end)

    map("n", prefix .. "s", function()
        vim.cmd("split")
        oil.open()
    end)
    map("n", prefix .. "S", function()
        vim.cmd("aboveleft split")
        oil.open()
    end)
    map("n", prefix .. "v", function()
        vim.cmd("vsplit")
        oil.open()
    end)
    map("n", prefix .. "V", function()
        vim.cmd("aboveleft vsplit")
        oil.open()
    end)
    map("n", prefix .. "F", oil.open_float)
end

return M
