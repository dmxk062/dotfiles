local theme = require("theme.colors")
local col = theme.colors
local pal = theme.palettes.default
local blend = theme.blend

local function add_with_prefix(to_append, prefix, table)
    for k, v in pairs(table) do
        -- expand * at the start to be a "relative" link
        if v.link and v.link:sub(1, 1) == "*" then
            v.link = prefix .. v.link:sub(2)
        end
        to_append[prefix .. k] = v
    end
end


-- Basics {{{
local colorscheme = {
    Normal                      = { fg = pal.fg0, bg = pal.bg0 },
    NormalFloat                 = { fg = pal.fg0, bg = pal.bg0 },
    FloatBorder                 = { fg = pal.bg3 },
    WinSeparator                = { fg = pal.bg2 },

    Search                      = { bg = pal.bg1 },
    CurSearch                   = { bg = pal.bg3 },
    IncSearch                   = { bg = pal.bg3 },
    Substitute                  = { bg = col.yellow, fg = pal.inverted },
    LeapMatch                   = { underline = true, fg = col.yellow },
    LeapLabel                   = { fg = pal.inverted, bg = col.yellow, nocombine = true },

    SpellBad                    = { sp = col.orange, undercurl = true },
    SpellRare                   = { sp = col.magenta, underdotted = true },
    SpellLocal                  = { sp = col.teal, underdotted = true },
    SpellCap                    = { sp = col.teal, undercurl = true },

    LineNr                      = { fg = col.bright_gray },
    LineNrAbove                 = { fg = blend(col.teal, col.bright_gray, 0.3) },
    LineNrBelow                 = { fg = blend(col.pink, col.bright_gray, 0.3) },
    CursorLineNr                = { fg = pal.fg0 },
    Cursor                      = { reverse = true },
    CursorLine                  = { bg = pal.bg1 },
    CursorColumn                = { bg = pal.bg1 },
    ColorColumn                 = { bg = pal.bg1, blend = 90 },
    Tabline                     = { link = "StatusLine" },
    StatusLine                  = { bg = pal.bg0 },
    Folded                      = { bg = blend(pal.bg1, pal.bg0, 0.4) },
    FoldNumber                  = { fg = col.magenta, italic = true },
    FoldColumn                  = { fg = pal.bg3 },
    SignColumn                  = { fg = pal.bg3 },
    EndOfBuffer                 = { fg = pal.bg1 },
    Visual                      = { bg = pal.bg1 },
    NonText                     = { fg = col.bright_gray },
    SpecialKey                  = { link = "NonText" },
    MatchParen                  = { bg = blend(pal.bg0, pal.bg1, 0.5) },

    Added                       = { fg = col.green },
    Deleted                     = { fg = col.red },
    Removed                     = { link = "Deleted" },
    Changed                     = { fg = col.yellow },
    DiffDelete                  = { bg = blend(col.red, pal.bg3, 0.3) },
    DiffChange                  = { bg = pal.bg1 },
    DiffAdd                     = { bg = pal.bg1, fg = col.green, italic = true },
    DiffText                    = { bg = pal.bg1, fg = col.yellow, italic = true },

    Question                    = { fg = col.bright_gray },
    Warnings                    = { fg = col.orange },
    ErrorMsg                    = { fg = col.red },
    MoreMSg                     = { fg = col.bright_gray },
    ModeMSg                     = { fg = col.bright_gray },

    Pmenu                       = { bg = pal.bg1, fg = pal.fg0 },
    PmenuSel                    = { bg = col.teal, fg = pal.inverted },
    PmenuKind                   = { fg = col.magenta },
    PmenuKindSel                = { fg = pal.inverted },
    PmenuExtra                  = { fg = pal.bg3 },
    PmenuExtraSel               = { fg = pal.bg3 },
    PmenuSbar                   = { fg = pal.fg2 },
    PmenuThumb                  = { fg = pal.fg0 },

    qfFileName                  = { fg = col.light_blue },
    qfLineNr                    = { fg = col.magenta },
    qfSeparator                 = { link = "@punctuation.delimiter" },
    QuickFixLine                = { bg = pal.bg1 },
    QuickFixLineNr              = { fg = col.purple },
    QuickFixFilename            = { link = "Identifier" },

    Directory                   = { fg = col.teal },
    Type                        = { link = "@type" },
    StorageClass                = { fg = col.light_blue },
    Structure                   = { link = "@type" },
    Struct                      = { link = "@type" },
    Statement                   = { fg = col.light_blue },
    Character                   = { link = "@character" },
    String                      = { link = "@string" },
    Number                      = { link = "@number" },
    Float                       = { link = "@float" },
    Constant                    = { link = "@constant" },
    Boolean                     = { link = "@boolean" },
    Label                       = { link = "@symbol" },
    Operator                    = { link = "@operator" },
    Exception                   = { fg = col.light_blue },
    Comment                     = { link = "@comment" },
    SpecialComment              = { link = "@comment.note" },
    PreProc                     = { fg = col.light_blue },
    Include                     = { link = "@keyword.import" },
    Define                      = { link = "@keyword" },
    Macro                       = { link = "@macro" },
    Typedef                     = { fg = col.light_blue },
    PreCondit                   = { fg = col.yellow },
    Special                     = { fg = pal.fg2 },
    SpecialChar                 = { fg = col.yellow },
    Tag                         = { fg = col.fg2 },
    Delimiter                   = { link = "@punctuation.delimiter" },
    Debug                       = { fg = col.red },
    Underlined                  = { fg = col.blue, underline = true },
    Ignore                      = { fg = pal.bg1 },
    Todo                        = { link = "@comment.todo" },
    Conceal                     = { bg = pal.bg0 },
    htmlLink                    = { fg = col.blue, italic = true, underline = true },
    markdownH1Delimiter         = { fg = col.light_cyan },
    markdownH2Delimiter         = { fg = col.red },
    markdownH3Delimiter         = { fg = col.green },
    Title                       = { link = "@markup.heading" },
    htmlH1                      = { link = "@markup.heading.1" },
    htmlH2                      = { link = "@markup.heading.2" },
    htmlH3                      = { link = "@markup.heading.3" },
    htmlH4                      = { link = "@markup.heading.4" },
    htmlH5                      = { link = "@markup.heading.5" },
    markdownH1                  = { link = "@markup.heading.1" },
    markdownH2                  = { link = "@markup.heading.2" },
    markdownH3                  = { link = "@markup.heading.3" },
    Error                       = { fg = col.red, bold = true, underline = true },
    Conditional                 = { link = "@keyword.conditional" },
    Function                    = { link = "@keyword.function" },
    Identifier                  = { fg = col.light_blue },
    Keyword                     = { link = "@keyword" },
    Repeat                      = { link = "@keyword.repeat" },
    Quote                       = { fg = pal.bg2 },
    CodeBlock                   = { bg = pal.bg1 },
    Dash                        = { fg = col.blue, bold = true },

    IndentBlanklineChar         = { fg = pal.bg1 },
    IndentBlanklineCharActive   = { fg = pal.bg3 },

    BinedCurrentLine            = { bg = pal.bg2 },
    TreesitterContext           = { bg = pal.bg2 },
    TreesitterContextLineNumber = { fg = col.teal, bg = pal.bg2 },
    MultiCursorCursor           = { bg = pal.bg3 },

    UndotreeTimeStamp           = { fg = col.light_blue },
    UndotreeCurrent             = { fg = col.teal },
    UndotreeNext                = { fg = col.yellow },
    UndotreeHead                = { fg = col.blue },
    UndotreeBranch              = { fg = col.magenta },
    UndotreeSavedSmall          = { fg = col.green },
    UndotreeSavedBig            = { fg = col.green, bg = pal.bg3 },

    Yanked                      = { bg = pal.bg1 },

    GrappleName                 = { fg = col.pink, italic = true },
    GrappleBold                 = { link = "Identifier" },
    GrappleCurrent              = { fg = col.teal },

    -- don't show those in italic
    helpExample                 = { link = "Normal" },

    manBold                     = { bg = pal.bg0 },
}
-- }}}

-- Ufo - Folds {{{
add_with_prefix(colorscheme, "Ufo", {
    FoldedFg     = {},
    FoldedBg     = {},
    PreviewThumb = {},

    FoldTitle    = { fg = col.teal, italic = true },
})
-- }}}

-- Treesitter {{{
add_with_prefix(colorscheme, "@", {
    number                           = { fg = col.magenta },
    float                            = { fg = col.magenta },
    macro                            = {},
    character                        = { fg = col.green },
    conditional                      = { fg = col.light_blue },
    boolean                          = { fg = col.teal },
    property                         = { fg = col.blue },
    constructor                      = { link = "*function" },
    operator                         = { fg = col.teal },
    symbol                           = { fg = col.magenta },

    ["comment"]                      = { fg = col.bright_gray, italic = true },
    ["comment.todo"]                 = { fg = col.yellow, italic = true, underline = true },
    ["comment.error"]                = { fg = col.red, italic = true, underline = true },
    ["comment.warning"]              = { fg = col.orange, italic = true, underline = true },
    ["comment.note"]                 = { fg = col.light_blue, italic = true, underline = true },

    ["string"]                       = { fg = col.green },
    ["string.csv"]                   = { link = "Normal" },
    ["string.psv"]                   = { link = "Normal" },
    ["string.tsv"]                   = { link = "Normal" },
    ["string.documentation"]         = { link = "*comment" },
    ["string.special.path"]          = { fg = col.teal },
    ["string.regex"]                 = { fg = col.orange },
    ["string.escape"]                = { fg = col.yellow },

    ["variable"]                     = { fg = pal.fg2 },
    ["variable.member"]              = { link = "*property" },
    ["variable.builtin"]             = { fg = pal.fg0, italic = true },
    ["variable.parameter.builtin"]   = { fg = col.light_blue, italic = true },

    ["constant"]                     = { fg = col.yellow },
    ["constant.builtin"]             = { fg = pal.fg2 },

    ["type"]                         = { fg = col.magenta },
    ["type.builtin"]                 = { fg = col.purple },

    ["function"]                     = { fg = col.light_blue },
    ["function.builtin"]             = { fg = col.light_cyan },

    ["punctuation.bracket"]          = { fg = col.bright_gray },
    ["punctuation.special"]          = { fg = col.light_cyan },
    ["punctuation.special.markdown"] = { fg = col.light_gray },
    ["punctuation.delimiter"]        = { fg = col.light_gray },

    ["attribute"]                    = { fg = col.yellow },
    ["attribute.builtin"]            = { fg = col.yellow },

    ["keyword"]                      = { fg = col.bright_gray },
    ["keyword.return"]               = { fg = col.light_blue, italic = true },
    ["keyword.repeat"]               = { fg = col.light_blue, italic = true },
    ["keyword.conditional"]          = { fg = col.light_blue, italic = true },
    ["keyword.import"]               = { fg = col.light_blue },
    ["keyword.function"]             = { link = "*function" },
    ["keyword.operator"]             = { link = "*operator" },

    ["text"]                         = { fg = pal.fg2 },
    ["text.reference"]               = { fg = col.magenta },
    ["text.emphasis"]                = { fg = pal.fg0, italic = true },
    ["text.underline"]               = { fg = pal.fg0, underline = true },
    ["text.literal"]                 = { fg = pal.fg2 },
    ["text.uri"]                     = { fg = col.blue, italic = true },
    ["text.strike"]                  = { fg = pal.fg0, strikethrough = true },
    ["text.title"]                   = { fg = col.blue },
    ["text.strong"]                  = { fg = pal.fg0, bold = true },

    ["diff.plus"]                    = { fg = col.green },
    ["diff.minus"]                   = { fg = col.red },
    ["diff.delta"]                   = { fg = col.yellow },

    ["tag"]                          = { link = "*keyword" },
    ["tag.attribute"]                = { fg = pal.fg0 },
    ["tag.builtin"]                  = { fg = col.light_blue },
    ["tag.delimiter"]                = { fg = col.bright_gray },

    ["markup.heading"]               = { fg = col.teal, bold = true },
    ["markup.heading.1"]             = { fg = col.yellow, bold = true },
    ["markup.heading.2"]             = { fg = col.green, bold = true },
    ["markup.heading.3"]             = { fg = col.teal, bold = true },
    ["markup.heading.4"]             = { fg = col.light_cyan, bold = true },
    ["markup.heading.5"]             = { fg = col.light_blue, bold = true },
    ["markup.heading.6"]             = { fg = col.blue, bold = true },
    ["markup.heading.7"]             = { fg = col.blue, bold = true },
    ["markup.heading.8"]             = { fg = col.blue, bold = true },
    ["markup.math"]                  = { italic = true },
    ["markup.raw.markdown_inline"]   = { bg = pal.bg1 },
    ["markup.raw.block.markdown"]    = { bg = pal.bg0 },
    ["markup.link"]                  = { fg = col.blue },
    ["markup.link.url"]              = { fg = col.blue, italic = true },
    ["markup.link.label"]            = { fg = col.blue },
    ["markup.quote"]                 = { italic = true },
    ["markup.list"]                  = { fg = col.light_blue },
    ["markup.list.checked"]          = { fg = col.bright_gray },
    ["markup.list.unchecked"]        = { fg = col.yellow, bg = pal.bg1 },

    ["character.printf"]             = {},
    ["number.printf"]                = { fg = col.magenta, bg = pal.bg1 },
    ["constant.printf"]              = { fg = col.yellow, bg = pal.bg1 },
    ["float.printf"]                 = { fg = col.magenta, bg = pal.bg1 },
    ["symbol.printf"]                = { fg = col.light_blue, bg = pal.bg1 },
    ["string.printf"]                = { fg = col.green, bg = pal.bg1 },
})
-- }}}

-- LSP overrides {{{
add_with_prefix(colorscheme, "@lsp.", {
    ["type.macro"]                      = { link = "@macro" },
    ["mod.deprecated"]                  = { fg = col.bright_gray, italic = true, strikethrough = true },
    ["typemod.function.defaultLibrary"] = { link = "@function.builtin" },
    -- so --HACK etc work
    ["type.comment"]                    = {},
    ["typemod.keyword.documentation"]   = { fg = col.light_blue },

    -- remove unnecessary highlights
    ["type.class.markdown"]             = {},
    -- tags in zettelkasten
    ["type.enumMember.markdown"]        = { fg = col.teal, bg = pal.bg1 },
})
-- }}}

-- Bufferline and Statusline {{{
add_with_prefix(colorscheme, "Sl", {
    AReg         = { bg = pal.bg1, fg = col.light_blue },
    IReg         = { fg = col.light_blue },
    ASpecial     = { bg = pal.bg1, fg = col.yellow },
    ISpecial     = { fg = col.yellow },
    AHelp        = { bg = pal.bg1, fg = col.green },
    IHelp        = { fg = col.green },
    ATab         = { bg = pal.bg1, fg = col.pink },
    ITab         = { fg = col.pink },
    ATerm        = { bg = pal.bg1, fg = col.orange },
    ITerm        = { fg = col.orange },
    IDir         = { fg = col.teal },
    ADir         = { bg = pal.bg1, fg = col.teal },
    IScratch     = { fg = col.pink },
    AScratch     = { bg = pal.bg1, fg = col.pink },
    IList        = { fg = col.magenta },
    AList        = { bg = pal.bg1, fg = col.magenta },
    IGit         = { fg = col.green },
    AGit         = { bg = pal.bg1, fg = col.green },
    IRegion      = { fg = col.magenta },
    ARegion      = { bg = pal.bg1, fg = col.magenta },

    AChanged     = { bg = pal.bg1, fg = col.yellow },
    IChanged     = { fg = col.yellow },
    AReadonly    = { bg = pal.bg1, fg = col.bright_gray },
    IReadonly    = { fg = col.bright_gray },
    AHidden      = { bg = pal.bg1, fg = col.bright_gray },
    IHidden      = { fg = col.bright_gray },
    ASL          = { fg = pal.bg1 },
    ASR          = { fg = pal.bg1 },
    IText        = { fg = pal.fg0 },
    AText        = { bg = pal.bg1, fg = pal.fg0 },
    AGrapple     = { bg = pal.bg1, fg = col.magenta },
    IGrapple     = { fg = col.magenta },

    Keys         = { fg = pal.fg0 },
    Register     = { fg = col.magenta, bg = pal.bg1 },
    Error        = { fg = col.red, bg = pal.bg1 },
    Warning      = { fg = col.orange, bg = pal.bg1 },
    Info         = { fg = col.blue, bg = pal.bg1 },
    Hint         = { fg = col.light_blue, bg = pal.bg1 },

    Row          = { fg = col.magenta },
    Col          = { fg = col.blue },

    DiffAdded    = { fg = col.green, bg = pal.bg1 },
    DiffChanged  = { fg = col.yellow, bg = pal.bg1 },
    DiffRemoved  = { fg = col.red, bg = pal.bg1 },

    SModeNormal  = { bg = pal.bg0, fg = col.teal },
    SModeInsert  = { bg = pal.bg0, fg = col.white },
    SModeCommand = { bg = pal.bg0, fg = col.green },
    SModeVisual  = { bg = pal.bg0, fg = col.light_blue },
    SModeReplace = { bg = pal.bg0, fg = col.red },

    ModeNormal   = { bg = col.teal, fg = pal.inverted },
    ModeInsert   = { bg = col.white, fg = pal.inverted },
    ModeCommand  = { bg = col.green, fg = pal.inverted },
    ModeVisual   = { bg = col.light_blue, fg = pal.inverted },
    ModeReplace  = { bg = col.red, fg = pal.inverted },
})
-- }}}

-- Startscreen {{{
add_with_prefix(colorscheme, "Startscreen", {
    Title0  = { fg = col.purple },
    Title1  = { fg = col.red },
    Title2  = { fg = col.orange },
    Title3  = { fg = col.yellow },
    Title4  = { fg = col.green },
    Title5  = { fg = col.teal },
    Title6  = { fg = col.light_blue },
    Title7  = { fg = col.blue },

    Text    = {},

    Files   = { fg = col.teal },
    Git     = { fg = col.green },
    Search  = { fg = col.light_blue },
    History = { fg = col.blue },
    Lazy    = { fg = col.yellow },
    Mason   = { fg = col.orange },
    Quit    = { fg = col.red },
    New     = { fg = col.purple },
    Shell   = { fg = col.pink },
})
-- }}}

-- Oil {{{
add_with_prefix(colorscheme, "Oil", {
    Link             = { fg = col.blue, bold = true },
    OrphanLink       = { fg = col.blue },
    Dir              = { fg = col.teal, bold = true },
    Hidden           = { fg = col.bright_gray },
    DirHidden        = { link = "*Hidden" },
    LinkTarget       = { fg = col.blue, italic = true },
    OrphanLinkTarget = { fg = col.red, italic = true },
    Socket           = { fg = col.magenta },
    BlockDev         = { fg = col.yellow, bg = pal.bg1 },
    CharDev          = { fg = col.green, bg = pal.bg1 },

    Executable       = { fg = col.green, bold = true },
    Code             = { fg = col.light_blue },
    Header           = { fg = col.yellow },
    Markup           = { fg = col.magenta },
    Text             = { fg = pal.fg2 },
    Bin              = { fg = col.orange },
    Archive          = { fg = col.orange, bg = pal.bg1 },
    Config           = { fg = col.purple },
    Meta             = { fg = col.light_blue, italic = true },
    Build            = { fg = col.green },
    Ignore           = { fg = col.bright_gray },
    Readme           = { fg = col.magenta },
    Style            = { link = "*Config" },

    Read             = { fg = col.yellow },
    Write            = { fg = col.orange },
    Exec             = { fg = col.green },
    Setuid           = { fg = col.red, bold = true },
    Sticky           = { fg = col.blue, bold = true },
    NoPerm           = { fg = pal.bg3 },

    Delete           = { fg = col.red, bold = true },
    Create           = { fg = col.green },
    Move             = { fg = col.orange },
    Copy             = { fg = col.yellow },
    Change           = { fg = col.magenta },

    TimeLastHour     = { fg = col.green },
    TimeLastDay      = { fg = col.teal },
    TimeLastWeek     = { fg = col.light_blue },
    TimeLastMonth    = { fg = col.blue },
    TimeLastYear     = { fg = blend(col.blue, pal.bg3, 0.8) },
    TimeSuperOld     = { fg = pal.bg3 },

    SizeNone         = { fg = pal.bg3 },
    SizeSmall        = { fg = pal.fg0 },
    SizeMedium       = { fg = col.yellow },
    SizeLarge        = { fg = col.orange },
    SizeHuge         = { fg = col.red },
})


add_with_prefix(colorscheme, "OilGitStatus", {
    IndexIgnored           = { fg = pal.bg3 },
    WorkingTreeIgnored     = { link = "*IndexIgnored" },
    IndexUntracked         = { fg = pal.fg2 },
    WorkingTreeUntracked   = { link = "*IndexUntracked" },
    IndexAdded             = { fg = col.green },
    WorkingTreeAdded       = { link = "*IndexAdded" },
    IndexCopied            = { fg = col.green },
    WorkingTreeCopied      = { link = "*IndexCopied" },
    IndexDeleted           = { fg = col.red },
    WorkingTreeDeleted     = { link = "*IndexDeleted" },
    IndexModified          = { fg = col.yellow },
    WorkingTreeModified    = { link = "*IndexModified" },
    IndexRenamed           = { fg = col.light_blue },
    WorkingTreeRenamed     = { link = "*IndexRenamed" },
    IndexTypeChanged       = { fg = col.orange },
    WorkingTreeTypeChanged = { link = "*IndexTypeChanged" },
    IndexUnmerged          = { fg = pal.fg0 },
    WorkingTreeUnmerged    = { link = "*IndexUnmerged" },
})

-- }}}

-- nvim-cmp {{{
add_with_prefix(colorscheme, "CmpItem", {
    Kind            = { fg = col.yellow },
    KindText        = { fg = pal.bg3 },
    KindLatex       = { fg = col.green },
    KindNeorg       = { fg = col.light_blue },
    KindMethod      = { fg = col.magenta },
    KindFunction    = { fg = col.teal },
    KindConstructor = { fg = col.magenta },
    KindField       = { fg = pal.fg0 },
    KindVariable    = { fg = pal.fg0 },
    KindInterface   = { fg = col.magenta },
    KindStruct      = { link = "*ItemKindInterface" },
    KindClass       = { link = "*ItemKindInterface" },
    KindModule      = { fg = col.green },
    KindFile        = { fg = col.yellow },
    KindFolder      = { fg = col.light_blue },
    KindSnippet     = { fg = col.yellow },
    KindConstant    = { fg = pal.fg0, bold = true, italic = true },
    KindEnumMember  = { fg = col.yellow },
    KindKeyword     = { fg = pal.fg0 },

    AbbrMatch       = { fg = col.magenta, bold = true },
    AbbrMatchFuzzy  = { fg = col.magenta, bold = true },
    Abbr            = { fg = pal.fg2 },
    Menu            = { fg = col.green },
})

-- }}}

-- LSP & Diagnostics {{{
add_with_prefix(colorscheme, "Lsp", {
    InlayHint      = { fg = col.bright_gray, italic = true },
    InfoBorder     = { fg = pal.bg3 },
    StaticMethod   = { fg = col.magenta },
    ReferenceText  = { link = "Substitute" },
    ReferenceRead  = { link = "Substitute" },
    ReferenceWrite = { link = "Substitute" },
})

add_with_prefix(colorscheme, "Diagnostic", {
    Error            = { fg = col.red },
    SignError        = { link = "*Error" },
    UnderlineError   = { undercurl = true, sp = col.red },
    VirtualTextError = { fg = col.red, italic = true },
    FloatingError    = { link = "*Error" },

    Warn             = { fg = col.orange },
    SignWarn         = { link = "*Warn" },
    UnderlineWarn    = { undercurl = true, sp = col.orange },
    VirtualTextWarn  = { fg = col.orange, italic = true },
    FloatingWarn     = { link = "*Warn" },

    Info             = { fg = col.blue },
    SignInfo         = { link = "*Info" },
    UnderlineInfo    = { undercurl = true, sp = col.blue },
    VirtualTextInfo  = { fg = col.blue, italic = true },
    FloatingInfo     = { link = "*Info" },

    Hint             = { fg = col.light_blue },
    SignHint         = { link = "*Hint" },
    UnderlineHint    = { undercurl = true, sp = col.light_blue },
    VirtualTextHint  = { fg = col.light_blue, italic = true },
    FloatingHint     = { link = "*Hint" },

    Ok               = { fg = col.green },
    SignOk           = { link = "*Ok" },
    UnderlineOk      = { undercurl = true, sp = col.green },
    VirtualTextOk    = { fg = col.green, italic = true },
    FloatingOk       = { link = "*Ok" },

    Deprecated       = { link = "@lsp.mod.deprecated" },
})
-- }}}

-- Mason {{{
add_with_prefix(colorscheme, "Mason", {
    Header                      = { fg = pal.bg0, bg = col.teal },
    HeaderSecondary             = { fg = pal.bg0, bg = col.teal },
    Highlight                   = { fg = col.magenta },
    HighlightBlock              = { fg = pal.bg0, bg = col.teal },
    HighlightBlockBold          = { link = "*HighlightBlock" },
    HighlightSecondary          = { link = "*Highlight" },
    HighlightSecondaryBlock     = { link = "*HighlightBlock" },
    HighlightSecondaryBlockBold = { link = "*HighlightBlockBold" },
    Muted                       = { fg = pal.bg3 },
    MutedBlock                  = { bg = pal.bg3 },
    MutedBlockBold              = { link = "*MutedBlock" },
    Backdrop                    = { link = "Normal" },
})
-- }}}

-- Overrides for vim syntax {{{
add_with_prefix(colorscheme, "zsh", {
    Deref       = { link = "@variable" },
    VariableDef = { link = "@variable" },
    Function    = { link = "@function" },
    KSHFunction = { link = "@function" },
    Operator    = { link = "@operator" },
})
-- }}}

-- git: gitsigns and fugitive {{{
add_with_prefix(colorscheme, "GitSigns", {
    Add                = { fg = pal.bg3 },
    AddNr              = { fg = pal.bg3 },
    AddLn              = { fg = pal.bg3 },
    Change             = { fg = col.yellow },
    ChangeNr           = { fg = pal.bg3 },
    ChangeLn           = { fg = pal.bg3 },
    ChangeDelete       = { fg = col.orange },
    Delete             = { fg = col.red },
    DeleteNr           = { fg = pal.bg3 },
    DeleteLn           = { fg = pal.bg3 },
    CurrentLineBlame   = { bg = pal.bg1, fg = pal.fg0, nocombine = true },
    AddInline          = { bg = pal.bg1, fg = col.green, italic = true },
    DeleteInline       = { bg = pal.bg1, fg = col.red, italic = true },
    ChangeInline       = { bg = pal.bg1, fg = col.yellow, italic = true },

    StagedAdd          = { fg = col.green, bold = true },
    StagedDelete       = { fg = col.red, bold = true },
    StagedChange       = { fg = col.yellow, bold = true },
    StagedChangeDelete = { fg = col.orange, bold = true },
})

add_with_prefix(colorscheme, "fugitive", {
    UntrackedSection = { fg = col.bright_gray },
})
-- }}

-- Telescope {{{
add_with_prefix(colorscheme, "Telescope", {
    PromptBorder   = { fg = pal.bg3 },
    PromptTitle    = { fg = col.teal },
    ResultsBorder  = { fg = pal.bg3 },
    PreviewBorder  = { fg = pal.bg3 },
    Selection      = { bg = pal.bg1 },
    PromptPrefix   = { fg = col.teal, bold = true },
    SelectionCaret = {},
    Matching       = { bg = pal.bg1 },

    PreviewExecute = { link = "OilExec" },
    PreviewRead    = { link = "OilRead" },
    PreviewWrite   = { link = "OilWrite" },
    PreviewSticky  = { link = "OilSticky" },
    PreviewLink    = { link = "OilLink" },
    PreviewHyphen  = { link = "OilNoPerm" },
    PreviewDate    = { fg = col.cyan },
})
-- }}}

return colorscheme
