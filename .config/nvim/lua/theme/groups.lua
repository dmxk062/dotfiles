local nord = require("theme.colors")
local col = nord.colors
local pal = nord.palettes.dark



local function with_prefix(prefix, table)
    local res = {}
    for k, v in pairs(table) do
        res[prefix .. k] = v
    end

    return res
end

local editor = {
    Normal = { fg = pal.fg0, bg = pal.bg0 },
    NormalFloat = { fg = pal.fg0, bg = pal.bg0 },
    FloatBorder = { fg = pal.bg3 },
    WinSeparator = { fg = pal.bg2 },

    Search = { bg = pal.bg1 },
    CurSearch = { bg = pal.bg3 },
    IncSearch = { bg = pal.bg3 },
    Substitute = { bg = col.orange, fg = pal.inverted },

    LineNr = { fg = col.bright_gray },
    CursorLineNr = { fg = pal.fg0 },

    Cursor = { reverse = true },
    CursorLine = { bg = pal.bg1 },
    CursorColumn = { bg = pal.bg1 },

    SpellBad = { sp = col.orange, undercurl = true },
    SpellRare = { sp = col.magenta, undercurl = true },
    SpellLocal = { sp = col.teal, undercurl = true },
    SpellCap = { sp = col.teal, undercurl = true },

    StatusLine = { bg = pal.bg0 },
    Tabline = { link = "StatusLine" },

    Visual = { bg = pal.bg2 },
    NonText = { fg = pal.bg1 },
    MatchParen = { fg = col.magenta, bg = pal.inverted, reverse = true }

}

local syntax = {
    Type = { fg = col.magenta },
    StorageClass = { fg = col.light_blue },
    Structure = { fg = col.magenta },
    Statement = { fg = col.light_blue },
    Character = {fg = col.green},
    String = {fg = col.green},
    Number = {fg = col.magenta},
    Float = {fg = col.magenta},
    Constant = {fg = col.yellow},
    Boolean = {fg = col.yellow},
    Label = {fg = col.magenta},
    Operator = {fg = col.light_blue},
    Exception = {fg = col.light_blue},

}

local oil = with_prefix("Oil", {
    Link = {fg = col.blue, bold = true},
    Dir  = {fg = col.teal, bold = true},
    LinkTarget = {fg = col.blue, italic = true},
    Socket = {fg = col.magenta},

    Read =  {fg = col.yellow},
    Write = {fg = col.orange},
    Exec =  {fg = col.green},
    Setuid = {fg = col.red, bold = true},
    Sticky = {fg = col.blue, bold = true},
    NoPerm = {fg = pal.bg3},

    Delete = {fg = col.red, bold = true},
    Create = {fg = col.green},
    Move = {fg = col.orange},
    Copy = {fg = col.yellow},
    Change = {fg = col.magenta},

    GitStatusIndexIgnored = {fg = pal.bg3},
    GitStatusWorkingTreeIgnored = {link = "OilGitStatusIndexIgnored"},
    GitStatusIndexUntracked = {link = "OilGitStatusIndexIgnored"},
    GitStatusWorkingTreeUntracked = {link = "OilGitStatusIndexIgnored"},
    GitStatusIndexAdded = {fg = col.green},
    GitStatusWorkingTreeAdded = {link = "OilGitStatusIndexAdded"},
    GitStatusIndexCopied = {fg = col.yellow},
    GitStatusWorkingTreeCopied = {link = "OilGitStatusIndexCopied"},
    GitStatusIndexDeleted = {fg = col.red},
    GitStatusWorkingTreeDeleted = {link = "OilGitStatusIndexDeleted"},
    GitStatusIndexModified = {fg = col.magenta},
    GitStatusWorkingTreeModified = {link = "OilGitStatusIndexModified"},
    GitStatusIndexRenamed = {fg = col.light_blue},
    GitStatusWorkingTreeRenamed = {link = "OilGitStatusIndexRenamed"},
    GitStatusIndexTypeChanged = {fg = col.orange},
    GitStatusWorkingTreeTypeChanged = {link = "OilGitStatusIndexTypeChanged"},
    GitStatusIndexUnmerged = {fg = pal.fg0},
    GitStatusWorkingTreeUnmerged = {link = "OilGitStatusIndexUnmerged"},
})

local treesitter = with_prefix("@", {
    number            = { fg = col.magenta },
    float             = { link = "@number" },
    constant          = { fg = col.yellow },
    text              = { fg = pal.fg0 },
    string            = { fg = col.green },
    ["string.regex"]  = { fg = col.orange },
    ["string.escape"] = { fg = col.yellow },
    operator          = { fg = col.light_blue },
})


return {
    editor,
    syntax,
    oil,
    treesitter
}
