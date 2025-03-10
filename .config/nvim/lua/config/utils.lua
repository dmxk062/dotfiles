local M = {}
local api = vim.api
local fn = vim.fn

-- Reusable code for my entire config

-- format buffer title {{{
-- names for special filetypes {{{1
local nomodified_names = {
    TelescopePrompt = { "[tel]" },
    undotree = { "[undo]" },
    fugitive = { "[git]", "git" },
    checkhealth = { "[health]" },
    lazy = { "[lazy]" },
    mason = { "[mason]" },
}

local modified_names = {
    gitcommit = { "[commit]", "git" },
    marked = { "[marks]" },
}
-- }}}

local function expand_home(path, length)
    local user = vim.env.USER
    local home = "/home/" .. user
    return fn.pathshorten(path:gsub("/tmp/workspaces_" .. user, "~tmp")
        :gsub(home .. "/ws", "~ws")
        :gsub(home .. "/.config", "~cfg")
        :gsub(home, "~"), length or 6)
end

local buf_list_type = {}
---@return string? name
---@return string kind
---@return boolean show_modified
function M.format_buf_name(buf, short)
    local term_title = vim.b[buf].term_title
    if term_title then
        return term_title, "term", false
    end

    local name = api.nvim_buf_get_name(buf)
    local ft = vim.bo[buf].filetype

    if ft == "oil" then
        local ret
        if vim.startswith(name, "oil-ssh://") then
            local _, _, host, path = name:find("//([^/]+)/(.*)")
            ret = "@" .. host .. ":" .. path
        else
            ret = expand_home(name:sub(#"oil://" + 1, -2), 3) .. "/"
        end
        return ret, "oil", true
    elseif vim.b[buf]._jhk_type then
        return fn.fnamemodify(name, ":t"), vim.b[buf]._jhk_type, true
    elseif ft == "help" then
        return fn.fnamemodify(name, ":t"):gsub("%.txt$", ""), "help", false
    elseif ft == "git" then
        return "[git]", "git", false
    elseif ft == "fugitiveblame" then
        return "[git-blame]", "git", false
    elseif ft == "man" then
        return fn.fnamemodify(name, ":t"), "help", false
    elseif ft == "qf" then
        if not buf_list_type[buf] then
            local win = fn.bufwinid(buf)
            local isloclist = fn.getwininfo(win)[1].loclist == 1
            buf_list_type[buf] = isloclist and "[loc]" or "[qf]"
        end
        return buf_list_type[buf], "list", false
    elseif nomodified_names[ft] then
        return nomodified_names[ft][1], nomodified_names[ft][2] or "special", false
    elseif modified_names[ft] then
        return modified_names[ft][1], modified_names[ft][2] or "special", true
    elseif vim.startswith(name, "fugitive://") then
        return expand_home(fn.fnamemodify(name:gsub("fugitive://.-.git//%d+/", ""), ":t")), "git", true
    end

    local normal_buf = vim.bo[buf].buftype == ""
    if name and name ~= "" then
        if normal_buf then
            local ret = expand_home(name)
            if short then
                ret = fn.fnamemodify(ret, ":t")
            end
            return ret, "reg", true
        else
            if vim.startswith(name, "oil-ssh://") then
                local _, _, host, path = name:find("//([^/]+)/(.*)")
                return "@" .. host .. ":" .. fn.fnamemodify(path, ":t"), "reg", true
            else
                -- try to get smth reasonable for plugin provided buffers
                return fn.fnamemodify(name, ":t"), "special", true
            end
        end
    end

    return nil, "empty", true
end

M.btypehighlights = {
    term = "Term",
    oil = "Dir",
    scratch = "Scratch",
    list = "List",
    git = "Git",
    reg = "Reg",
    empty = "Reg",
    special = "Special",
    help = "Help",
    region = "Region",
}

M.btypesymbols = {
    term = "!",
    oil = ":",
    scratch = "&",
    list = "$",
    git = "@",
    reg = "#",
    empty = "#",
    special = "*",
    help = "?",
    region = ">",
}

-- }}}

-- highlight file path {{{
-- patterns {{{1
local extension_highlights = {
    ["a"]       = "Bin",
    ["c"]       = "Code",
    ["cfg"]     = "Config",
    ["conf"]    = "Config",
    ["cpp"]     = "Code",
    ["css"]     = "Style",
    ["desktop"] = "Config",
    ["go"]      = "Code",
    ["gz"]      = "Archive",
    ["h"]       = "Header",
    ["hs"]      = "Code",
    ["html"]    = "Markup",
    ["ini"]     = "Config",
    ["jar"]     = "Archive",
    ["js"]      = "Code",
    ["json"]    = "Markup",
    ["log"]     = "Info",
    ["lua"]     = "Code",
    ["md"]      = "Text",
    ["mk"]      = "Build",
    ["o"]       = "Bin",
    ["py"]      = "Code",
    ["pyc"]     = "Bin",
    ["rc"]      = "Config",
    ["rs"]      = "Code",
    ["scss"]    = "Style",
    ["sh"]      = "Code",
    ["so"]      = "Bin",
    ["tar"]     = "Archive",
    ["tex"]     = "Markup",
    ["toml"]    = "Config",
    ["ts"]      = "Code",
    ["txt"]     = "Text",
    ["xhtml"]   = "Markup",
    ["xml"]     = "Markup",
    ["xz"]      = "Archive",
    ["yaml"]    = "Config",
    ["yuck"]    = "Code",
    ["zip"]     = "Archive",
    ["zsh"]     = "Code",
}

-- case insensitive
local name_highlights = {
    [".clang-format"]         = "Meta",
    [".clangd"]               = "Meta",
    [".config/"]              = "Config",
    [".git/"]                 = "Ignore",
    [".gitconfig"]            = "Meta",
    [".gitignore"]            = "Meta",
    ["changelog.md"]          = "Readme",
    ["compile_commands.json"] = "Ignore",
    ["go.mod"]                = "Build",
    ["license"]               = "Readme",
    ["license.md"]            = "Readme",
    ["license.txt"]           = "Readme",
    ["makefile"]              = "Build",
    ["readme"]                = "Readme",
    ["readme.md"]             = "Readme",
    ["readme.txt"]            = "Readme",
    ["todo.md"]               = "Readme",
}
-- }}}

function M.highlight_fname(path, entry, is_hidden)
    if entry then
        path = entry.name
    end

    local name = path:lower() .. (entry and (entry.type == "directory" and "/") or "")
    if name_highlights[name] then
        return "Oil" .. name_highlights[name]
    end

    -- dont try to override directories or links, oil handles them well
    if entry then
        if entry.type == "directory" or entry.type == "link" then
            return
        elseif entry.type == "char" then
            return "OilCharDev"
        elseif entry.type == "block" then
            return "OilBlockDev"
        elseif entry.type == "socket" then
            return "OilSocket"
        end

        if entry.meta.stat and bit.band(entry.meta.stat.mode, 0x49) ~= 0 then
            return "OilExecutable"
        end
    end
    local ext = path:match("%.(%w+)$")
    if ext and extension_highlights[ext] then
        return "Oil" .. extension_highlights[ext]
    end

    if name:sub(-1) == "/" then
        return "OilDir"
    end

    if is_hidden then
        return "OilHidden"
    end

    return "OilFile"
end

-- }}}

-- Windows {{{
---@param args {enter: boolean}
function M.open_window_smart(buffer, args)
    local height = api.nvim_win_get_height(0)
    local width = api.nvim_win_get_width(0)

    return api.nvim_open_win(buffer, args.enter, {
        vertical = height * 2.6 < width
    })
end

-- }}}

-- easier mapping {{{
---@alias nvim_mode "n"|"i"|"c"|"v"|"x"|"s"|"o"|"t"|{}

---@param mode nvim_mode
---@param keys string
---@param action string|function
---@param opts vim.keymap.set.Opts|nil
function M.map(mode, keys, action, opts)
    vim.keymap.set(mode, keys, action, opts or {})
end

---@param mode nvim_mode
---@param keys string
---@param opts vim.keymap.del.Opts?
function M.unmap(mode, keys, opts)
    vim.keymap.del(mode, keys, opts or {})
end

---@param bufnr integer
---@param mode nvim_mode
---@param keys string
---@param opts vim.keymap.del.Opts?
function M.lunmap(bufnr, mode, keys, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.del(mode, keys, opts)
end

---@param bufnr integer
---@param mode nvim_mode
---@param keys string
---@param action string|function
---@param opts vim.keymap.set.Opts|nil
function M.lmap(bufnr, mode, keys, action, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, keys, action, opts)
end

---@param bufnr integer
---@param prefix string?
---@return fun(mode: nvim_mode, keys: string, action: string|function, opts: vim.keymap.set.Opts?)
function M.local_mapper(bufnr, prefix)
    if prefix then
        return function(mode, keys, action, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, prefix .. keys, action, opts)
        end
    else
        return function(mode, keys, action, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, keys, action, opts)
        end
    end
end

---@param mode nvim_mode
---@param keys string
---@param string string
function M.abbrev(mode, keys, string)
    if type(mode) == "table" then
        vim.keymap.set(vim.tbl_map(function(s)
            return s .. "a"
        end, mode), keys, string)
    else
        vim.keymap.set(mode .. "a", keys, string)
    end
end

-- }}}



return M
