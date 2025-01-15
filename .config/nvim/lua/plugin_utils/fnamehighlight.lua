-- Highlights for file extensions {{{

local extension_highlights = {
    ["a"]       = "Bin",
    ["c"]       = "Source",
    ["cfg"]     = "Config",
    ["conf"]    = "Config",
    ["cpp"]     = "Source",
    ["css"]     = "Style",
    ["desktop"] = "Config",
    ["go"]      = "Source",
    ["gz"]      = "Archive",
    ["h"]       = "Code",
    ["hs"]      = "Source",
    ["html"]    = "Markup",
    ["ini"]     = "Config",
    ["jar"]     = "Archive",
    ["js"]      = "Code",
    ["json"]    = "Markup",
    ["log"]     = "Info",
    ["lua"]     = "Source",
    ["md"]      = "Text",
    ["mk"]      = "Build",
    ["o"]       = "Bin",
    ["py"]      = "Script",
    ["pyc"]     = "Bin",
    ["rc"]      = "Config",
    ["rs"]      = "Source",
    ["yuck"]    = "Source",
    ["scss"]    = "Style",
    ["sh"]      = "Script",
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
    ["changelog.md"]  = "Readme",
    ["go.mod"]        = "Build",
    ["license"]       = "Readme",
    ["license.md"]    = "Readme",
    ["license.txt"]   = "Readme",
    ["makefile"]      = "Build",
    ["readme"]        = "Readme",
    ["readme.md"]     = "Readme",
    ["readme.txt"]    = "Readme",
    ["todo.md"]       = "Readme",
} -- }}}

return {
    highlight_fname = function(path, entry, is_hidden)
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

        if is_hidden then
            return "OilHidden"
        end

        return "OilFile"
    end
}
