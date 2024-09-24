local theme = require("theme.colors")
local col = theme.colors
local pal = theme.palettes.dark

local function with_prefix(prefix, table)
    local res = {}
    for k, v in pairs(table) do
        res[prefix .. k] = v
    end
    return res
end

---@param col1 string
---@param col2 string
---@param alpha decimal
local function blend(col1, col2, alpha)
    local r1, g1, b1 = tonumber(col1:sub(2, 3), 16), tonumber(col1:sub(4, 5), 16), tonumber(col1:sub(6, 7), 16)
    local r2, g2, b2 = tonumber(col2:sub(2, 3), 16), tonumber(col2:sub(4, 5), 16), tonumber(col2:sub(6, 7), 16)

    local rr = math.floor((r1 * alpha) + (r2 * (1 - alpha)))
    local gr = math.floor((g1 * alpha) + (g2 * (1 - alpha)))
    local br = math.floor((b1 * alpha) + (b2 * (1 - alpha)))

    return string.format("#%02X%02X%02x", rr, gr, br)
end

local editor = {
    Normal       = { fg = pal.fg0, bg = pal.bg0 },
    NormalFloat  = { fg = pal.fg0, bg = pal.bg0 },
    FloatBorder  = { fg = pal.bg3 },
    WinSeparator = { fg = pal.bg2 },

    ColorColumn  = { bg = pal.bg1, blend = 90 },

    Search       = { bg = pal.bg1 },
    CurSearch    = { bg = pal.bg3 },
    IncSearch    = { bg = pal.bg3 },
    Substitute   = { bg = col.yellow, fg = pal.inverted },

    LineNr       = { fg = col.bright_gray },
    LineNrAbove  = { fg = blend(col.magenta, pal.bg3, 0.5) },
    LineNrBelow  = { fg = blend(col.blue, pal.bg3, 0.5) },
    CursorLineNr = { fg = pal.fg0 },
    Cursor       = { reverse = true },
    CursorLine   = { bg = pal.bg1 },
    CursorColumn = { bg = pal.bg1 },

    SpellBad     = { sp = col.orange, undercurl = true },
    SpellRare    = { sp = col.magenta, undercurl = true },
    SpellLocal   = { sp = col.teal, undercurl = true },
    SpellCap     = { sp = col.teal, undercurl = true },

    StatusLine   = { bg = pal.bg0 },
    Tabline      = { link = "StatusLine" },
    Folded       = { fg = pal.bg3 },
    FoldColumn   = { fg = pal.bg3 },
    SignColumn   = { fg = pal.bg3 },


    Visual            = { bg = pal.bg2 },
    NonText           = { fg = col.bright_gray },
    SpecialKey        = { link = "NonText" },
    MatchParen        = { fg = col.magenta, bg = pal.bg2, bold = true },

    DiffAdd           = { fg = col.green },
    -- the actual changes are highlighted anyways
    DiffChange        = {},
    DiffDelete        = { fg = col.red },
    DiffText          = { fg = col.magenta, italic = true },

    Question          = { fg = col.bright_gray },
    Warnings          = { fg = col.orange },
    ErrorMsg          = { fg = col.red },
    MoreMSg           = { fg = col.bright_gray },
    ModeMSg           = { fg = col.bright_gray },

    EndOfBuffer       = { fg = pal.bg1 },

    DiagnosticError   = { fg = col.red },
    DiagnosticOk      = { fg = col.green },
    DiagnosticWarning = { fg = col.orange },

    Title             = { fg = col.teal, bold = true },

    QuickFixLine      = { fg = col.teal },
    Directory         = { fg = col.teal },

    Pmenu             = { bg = pal.bg1, fg = pal.fg0 },
    PmenuSel          = { bg = col.teal, fg = pal.inverted },
    PmenuKind         = { fg = col.magenta },
    PmenuKindSel      = { fg = pal.inverted },
    PmenuExtra        = { fg = pal.bg3 },
    PmenuExtraSel     = { fg = pal.bg3 },
    PmenuSbar         = { fg = pal.fg2 },
    PmenuThumb        = { fg = pal.fg0 },

}

local syntax = {
    Type                = { fg = col.magenta },
    StorageClass        = { fg = col.light_blue },
    Structure           = { fg = col.magenta },
    Statement           = { fg = col.light_blue },
    Character           = { fg = col.green },
    String              = { fg = col.green },
    Number              = { fg = col.magenta },
    Float               = { fg = col.magenta },
    Constant            = { fg = col.yellow },
    Boolean             = { fg = col.yellow },
    Label               = { fg = col.magenta },
    Operator            = { link = "@operator" },
    Exception           = { fg = col.light_blue },
    Comment             = { fg = col.bright_gray, italic = true },
    SpecialComment      = { fg = col.light_cyan, italic = true },
    PreProc             = { fg = col.light_blue },
    Include             = { fg = col.light_blue },
    Define              = { fg = col.light_blue },
    Macro               = { fg = col.light_cyan },
    Typedef             = { fg = col.light_blue },
    PreCondit           = { fg = col.yellow },
    Special             = { fg = pal.fg2 },
    SpecialChar         = { fg = col.yellow },
    Tag                 = { fg = col.fg2 },
    Delimiter           = { fg = pal.fg0 },
    Debug               = { fg = col.red },
    Underlined          = { fg = col.blue, underline = true },
    Ignore              = { fg = pal.bg1 },
    Todo                = { fg = col.yellow, bold = true, italic = true },
    Conceal             = { bg = pal.bg0 },
    htmlLink            = { fg = col.blue, italic = true, underline = true },
    markdownH1Delimiter = { fg = col.light_cyan },
    markdownH2Delimiter = { fg = col.red },
    markdownH3Delimiter = { fg = col.green },
    htmlH1              = { fg = col.light_cyan, bold = true },
    htmlH2              = { fg = col.red, bold = true },
    htmlH3              = { fg = col.green, bold = true },
    htmlH4              = { fg = col.magenta, bold = true },
    htmlH5              = { fg = col.light_blue, bold = true },
    markdownH1          = { fg = col.light_cyan, bold = true },
    markdownH2          = { fg = col.red, bold = true },
    markdownH3          = { fg = col.green, bold = true },
    Error               = { fg = col.red, bold = true, underline = true },
    Conditional         = { fg = col.blue },
    Function            = { fg = col.light_cyan },
    Identifier          = { fg = col.light_blue },
    Keyword             = { fg = pal.fg0 },
    Repeat              = { fg = col.yellow },
    Quote               = { fg = pal.bg2 },
    CodeBlock           = { bg = pal.bg1 },
    Dash                = { fg = col.blue, bold = true },
}

local oil = with_prefix("Oil", {
    Link                            = { fg = col.blue, bold = true },
    Dir                             = { fg = col.teal, bold = true },
    LinkTarget                      = { fg = col.blue, italic = true },
    Socket                          = { fg = col.magenta },

    Read                            = { fg = col.yellow },
    Write                           = { fg = col.orange },
    Exec                            = { fg = col.green },
    Setuid                          = { fg = col.red, bold = true },
    Sticky                          = { fg = col.blue, bold = true },
    NoPerm                          = { fg = pal.bg3 },

    Delete                          = { fg = col.red, bold = true },
    Create                          = { fg = col.green },
    Move                            = { fg = col.orange },
    Copy                            = { fg = col.yellow },
    Change                          = { fg = col.magenta },

    TimeLastHour                    = { fg = col.green },
    TimeLastDay                     = { fg = col.teal },
    TimeLastWeek                    = { fg = col.light_blue },
    TimeLastMonth                   = { fg = col.blue },
    TimeLastYear                    = { fg = blend(col.blue, pal.bg3, 0.8) },
    TimeSuperOld                    = { fg = pal.bg3 },

    SizeNone                        = { fg = pal.bg3 },
    SizeSmall                       = { fg = pal.fg0 },
    SizeMedium                      = { fg = col.yellow },
    SizeLarge                       = { fg = col.orange },
    SizeHuge                        = { fg = col.red },

    GitStatusIndexIgnored           = { fg = pal.bg3 },
    GitStatusWorkingTreeIgnored     = { link = "OilGitStatusIndexIgnored" },
    GitStatusIndexUntracked         = { link = "OilGitStatusIndexIgnored" },
    GitStatusWorkingTreeUntracked   = { link = "OilGitStatusIndexIgnored" },
    GitStatusIndexAdded             = { fg = col.green },
    GitStatusWorkingTreeAdded       = { link = "OilGitStatusIndexAdded" },
    GitStatusIndexCopied            = { fg = col.yellow },
    GitStatusWorkingTreeCopied      = { link = "OilGitStatusIndexCopied" },
    GitStatusIndexDeleted           = { fg = col.red },
    GitStatusWorkingTreeDeleted     = { link = "OilGitStatusIndexDeleted" },
    GitStatusIndexModified          = { fg = col.magenta },
    GitStatusWorkingTreeModified    = { link = "OilGitStatusIndexModified" },
    GitStatusIndexRenamed           = { fg = col.light_blue },
    GitStatusWorkingTreeRenamed     = { link = "OilGitStatusIndexRenamed" },
    GitStatusIndexTypeChanged       = { fg = col.orange },
    GitStatusWorkingTreeTypeChanged = { link = "OilGitStatusIndexTypeChanged" },
    GitStatusIndexUnmerged          = { fg = pal.fg0 },
    GitStatusWorkingTreeUnmerged    = { link = "OilGitStatusIndexUnmerged" },
})

local cmp = with_prefix("CmpItem", {
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
    KindStruct      = { link = "CmpItemKindInterface" },
    KindClass       = { link = "CmpItemKindInterface" },
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

local treesitter = with_prefix("@", {
    number                         = { fg = col.magenta },
    float                          = { fg = col.magenta },
    macro                          = { fg = col.teal },
    character                      = { fg = col.green },
    conditional                    = { fg = col.light_blue },
    boolean                        = { fg = col.teal },
    property                       = { fg = col.blue },
    constructor                    = { fg = col.light_blue },
    operator                       = { fg = col.teal },
    symbol                         = { fg = col.magenta },

    ["comment"]                    = { fg = col.bright_gray, italic = true },
    ["comment.todo"]               = { fg = col.yellow, italic = true },
    ["comment.error"]              = { fg = col.red, italic = true },
    ["comment.warning"]            = { fg = col.orange, italic = true },
    ["comment.note"]               = { fg = col.light_blue, italic = true },

    ["string"]                     = { fg = col.green },
    ["string.documentation"]       = { link = "@comment" },
    ["string.special.path"]        = { fg = col.teal },
    ["string.regex"]               = { fg = col.orange },
    ["string.escape"]              = { fg = col.yellow },

    ["variable"]                   = { fg = col.light_blue },
    ["variable.builtin"]           = { fg = pal.fg0, italic = true },
    ["variable.parameter.builtin"] = { fg = col.light_blue, italic = true },

    ["constant"]                   = { fg = col.yellow },
    ["constant.builtin"]           = { fg = pal.fg2 },

    ["type"]                       = { fg = col.magenta },
    ["type.builtin"]               = { fg = col.light_blue },

    ["function"]                   = { fg = col.light_cyan },
    ["function.builtin"]           = { fg = col.light_cyan },

    ["punctuation.bracket"]        = { fg = col.light_cyan },
    ["punctuation.special"]        = { fg = col.light_cyan },
    ["punctuation.delimiter"]      = { fg = col.light_gray },


    ["attribute"]                  = { fg = col.yellow },
    ["attribute.builtin"]          = { fg = col.yellow },

    ["keyword"]                    = { fg = col.light_blue },
    ["keyword.return"]             = { fg = col.light_blue },
    ["keyword.function"]           = { fg = col.light_cyan },
    ["keyword.operator"]           = { fg = col.light_cyan },

    ["text"]                       = { fg = pal.fg2 },
    ["text.reference"]             = { fg = col.magenta },
    ["text.emphasis"]              = { fg = pal.fg0, italic = true },
    ["text.underline"]             = { fg = pal.fg0, underline = true },
    ["text.literal"]               = { fg = pal.fg2 },
    ["text.uri"]                   = { fg = col.blue, italic = true },
    ["text.strike"]                = { fg = pal.fg0, strikethrough = true },
    ["text.title"]                 = { fg = col.blue },
    ["text.strong"]                = { fg = pal.fg0, bold = true },

    ["diff.plus"]                  = { link = "DiffAdd" },
    ["diff.minus"]                 = { link = "DiffDelete" },
    ["diff.delta"]                 = { link = "DiffChange" },

    ["tag"]                        = { link = "@keyword" },
    ["tag.attribute"]              = { fg = pal.fg0 },
    ["tag.builtin"]                = { fg = col.light_blue },
    ["tag.delimiter"]              = { fg = col.bright_gray },

    ["markup.heading"]             = { link = "Title" },
    ["markup.heading.1"]           = { fg = col.yellow, bold = true },
    ["markup.heading.2"]           = { fg = col.green, bold = true },
    ["markup.heading.3"]           = { fg = col.teal, bold = true },
    ["markup.heading.4"]           = { fg = col.light_cyan, bold = true },
    ["markup.heading.5"]           = { fg = col.light_blue, bold = true },
    ["markup.heading.6"]           = { fg = col.blue, bold = true },
    ["markup.heading.7"]           = { fg = col.blue, bold = true },
    ["markup.heading.8"]           = { fg = col.blue, bold = true },
    ["markup.math"]                = { italic = true },
    ["markup.raw.markdown_inline"] = { bg = pal.bg1 },
    ["markup.link"]                = { fg = col.fg2, italic = true },
    ["markup.link.url"]            = { fg = col.blue, underline = true, italic = true },
    ["markup.link.label"]          = { fg = col.fg2, italic = true },
    ["markup.quote"]               = { fg = col.bright_gray, italic = true },
    ["markup.list"]                = { fg = col.light_gray, bold = true },
    ["markup.list.checked"]        = { fg = col.light_gray },
    ["markup.list.unchecked"]      = { fg = col.yellow, bold = true },

    ["lsp.type.macro"]             = { link = "@macro" },
    ["lsp.mod.deprecated"]         = { fg = col.bright_gray, italic = true, strikethrough = true },
})

local lsp = with_prefix("Lsp", {

    InlayHint                         = { fg = col.bright_gray, italic = true },
    InfoBorder                        = { fg = pal.bg3 },
    DiagnosticsDefaultError           = { fg = col.red },
    DiagnosticsSignError              = { fg = col.red },
    DiagnosticsFloatingError          = { fg = col.red },
    DiagnosticsVirtualTextError       = { fg = col.red },
    DiagnosticsUnderlineError         = { undercurl = true, sp = col.red },
    DiagnosticsDefaultWarning         = { fg = col.orange },
    DiagnosticsSignWarning            = { fg = col.orange },
    DiagnosticsFloatingWarning        = { fg = col.orange },
    DiagnosticsVirtualTextWarning     = { fg = col.orange },
    DiagnosticsUnderlineWarning       = { undercurl = true, sp = col.orange },
    DiagnosticsDefaultInformation     = { fg = col.blue },
    DiagnosticsSignInformation        = { fg = col.blue },
    DiagnosticsFloatingInformation    = { fg = col.blue },
    DiagnosticsVirtualTextInformation = { fg = col.blue },
    StaticMethod                      = { fg = col.magenta },
    DiagnosticsUnderlineInformation   = { undercurl = true, sp = col.blue },
    DiagnosticsDefaultHint            = { fg = col.light_blue },
    DiagnosticsSignHint               = { fg = col.light_blue },
    DiagnosticsFloatingHint           = { fg = col.light_blue },
    DiagnosticsVirtualTextHint        = { fg = col.light_blue },
    DiagnosticsUnderlineHint          = { undercurl = true, sp = col.blue },
    ReferenceText                     = { fg = pal.fg2, bg = pal.bg1 },
    ReferenceRead                     = { fg = pal.fg2, bg = pal.bg1 },
    ReferenceWrite                    = { fg = pal.fg2, bg = pal.bg1 },

})

local diag = with_prefix("Diagnostic", {
    Error            = { link = "LspDiagnosticsDefaultError" },
    Warn             = { link = "LspDiagnosticsDefaultWarning" },
    Info             = { link = "LspDiagnosticsDefaultInformation" },
    Hint             = { link = "LspDiagnosticsDefaultHint" },
    Deprecated       = { link = "@lsp.mod.deprecated" },
    VirtualTextWarn  = { link = "LspDiagnosticsVirtualTextWarning" },
    UnderlineWarn    = { link = "LspDiagnosticsUnderlineWarning" },
    FloatingWarn     = { link = "LspDiagnosticsFloatingWarning" },
    VirtualTextError = { link = "LspDiagnosticsVirtualTextError" },
    UnderlineError   = { link = "LspDiagnosticsUnderlineError" },
    FloatingError    = { link = "LspDiagnosticsFloatingError" },
    VirtualTextInfo  = { link = "LspDiagnosticsVirtualTextInformation" },
    UnderlineInfo    = { link = "LspDiagnosticsUnderlineInformation" },
    FloatingInfo     = { link = "LspDiagnosticsFloatingInformation" },
    VirtualTextHint  = { link = "LspDiagnosticsVirtualTextHint" },
    UnderlineHint    = { link = "LspDiagnosticsUnderlineHint" },
    FloatingHint     = { link = "LspDiagnosticsFloatingHint" },

    SignError        = { fg = col.red, bold = true },
    SignWarn         = { fg = col.orange, bold = true },
    SignInfo         = { fg = col.blue, bold = true },
    SignHint         = { fg = col.light_blue, bold = true },
})

local startscreen = with_prefix("StartScreen", {
    ShortcutGeneric = { fg = col.magenta },
    ShortcutFiles   = { fg = col.teal },
    ShortcutSearch  = { fg = col.orange },
    ShortcutGrep    = { fg = col.yellow },
    ShortcutDir     = { fg = col.teal },
    ShortcutHistory = { fg = col.blue },
    ShortcutNeorg   = { fg = col.light_blue },
    ShortcutLazy    = { fg = col.green },
    ShortcutQuit    = { fg = col.red },

    History         = { fg = col.blue },
    Title1          = { fg = col.red },
    Title2          = { fg = col.orange },
    Title3          = { fg = col.yellow },
    Title4          = { fg = col.green },
    Title5          = { fg = col.teal },
    Title6          = { fg = col.light_blue },
    Title7          = { fg = col.blue },
    Title8          = { fg = col.magenta },
})

local mason = with_prefix("Mason", {
    Header                      = { fg = pal.bg0, bg = col.teal },
    HeaderSecondary             = { fg = pal.bg0, bg = col.teal },
    Highlight                   = { fg = col.magenta },
    HighlightBlock              = { fg = pal.bg0, bg = col.teal },
    HighlightBlockBold          = { link = "MasonHighlightBlock" },
    HighlightSecondary          = { link = "MasonHighlight" },
    HighlightSecondaryBlock     = { link = "MasonHighlightBlock" },
    HighlightSecondaryBlockBold = { link = "MasonHighlightBlockBold" },
    Muted                       = { fg = pal.bg3 },
    MutedBlock                  = { bg = pal.bg3 },
    MutedBlockBold              = { link = "MasonMutedBlock" },
})

local gitsigns = with_prefix("GitSigns", {
    Add                = { fg = pal.bg3 },
    AddNr              = { fg = pal.bg3 },
    AddLn              = { fg = pal.bg3 },
    Change             = { fg = col.magenta },
    ChangeNr           = { fg = pal.bg3 },
    ChangeLn           = { fg = pal.bg3 },
    Delete             = { fg = col.red },
    DeleteNr           = { fg = pal.bg3 },
    DeleteLn           = { fg = pal.bg3 },
    CurrentLineBlame   = { bg = pal.bg1, fg = pal.fg0, nocombine = true },
    AddInline          = { fg = col.green, italic = true },
    DeleteInline       = { fg = col.red, italic = true },
    ChangeInline       = { italic = true, bold = true },

    StagedAdd          = { fg = pal.bg3, bold = true },
    StagedDelete       = { fg = col.red, bold = true },
    StagedChange       = { fg = col.magenta, bold = true },
    StagedChangeDelete = { fg = col.magenta, bold = true },
})

local telescope = with_prefix("Telescope", {
    PromptBorder   = { fg = pal.bg3 },
    PromptTitle    = { fg = col.teal },
    ResultsBorder  = { fg = pal.bg3 },
    PreviewBorder  = { fg = pal.bg3 },
    Selection      = { fg = col.teal, bold = true },
    PromptPrefix   = { fg = col.teal, bold = true },
    SelectionCaret = {},
    Matching       = { fg = col.teal },

    PreviewExecute = { link = "OilExec" },
    PreviewRead    = { link = "OilRead" },
    PreviewWrite   = { link = "OilWrite" },
    PreviewSticky  = { link = "OilSticky" },
    PreviewLink    = { link = "OilLink" },
    PreviewHyphen  = { link = "OilNoPerm" },
    PreviewDate    = { fg = col.cyan },
})

local extra = {
    -- diffAdded                 = { fg = col.green },
    -- diffRemoved               = { fg = col.red },
    -- diffChanged               = { fg = col.magenta },
    -- diffOldFile               = { fg = col.yellow },
    -- diffNewFile               = { fg = col.orange },
    -- diffFile                  = { fg = col.teal },
    -- diffLine                  = { fg = pal.bg3 },
    -- diffIndexLine             = { fg = col.light_blue },

    Added                       = { link = "diffAdded" },
    Changed                     = { link = "diffChanged" },
    Removed                     = { link = "diffRemoved" },

    LeapMatch                   = { underline = true, fg = col.yellow },
    LeapLabel                   = { fg = pal.inverted, bg = col.yellow, nocombine = true },
    -- LeapLabelPrimary          = { fg = pal.inverted, bg = col.magenta, nocombine = true },

    IndentBlanklineChar         = { fg = pal.bg1 },
    IndentBlanklineCharActive   = { fg = pal.bg3 },

    BinedCurrentLine            = { bg = pal.bg2 },
    TreesitterContext           = { bg = pal.bg2 },
    TreesitterContextLineNumber = { fg = col.teal },

    MultiCursorCursor           = { bg = pal.bg3 },
}

local neorg = with_prefix("@neorg.", {
    ["code_block"]           = { link = "CodeBlock" },
    ["markup.verbatim.norg"] = { link = "@markup.raw.markdown_inline" },
    undone                   = { fg = pal.bg3 },
    cancelled                = { fg = pal.bg3 },
    done                     = { fg = col.green },
    pending                  = { fg = col.magenta },
    urgent                   = { fg = col.red },
    recurring                = { fg = col.teal },
    uncertain                = { fg = col.light_cyan, },
    on_hold                  = { fg = col.light_blue },
    ["quote.1"]              = { italic = true, fg = blend(col.yellow, pal.fg0, 0.7) },
    ["quote.2"]              = { italic = true, fg = blend(col.green, pal.fg0, 0.7) },
    ["quote.3"]              = { italic = true, fg = blend(col.teal, pal.fg0, 0.7) },
    ["quote.4"]              = { italic = true, fg = blend(col.light_cyan, pal.fg0, 0.7) },
    ["quote.5"]              = { italic = true, fg = blend(col.light_blue, pal.fg0, 0.7) },
    ["quote.6"]              = { italic = true, fg = blend(col.blue, pal.fg0, 0.7) },
    ["quote.7"]              = { link = "@neorg.quote.6" },
    ["quote.8"]              = { link = "@neorg.quote.6" },
})


return {
    editor,
    syntax,
    oil,
    cmp,
    treesitter,
    lsp,
    telescope,
    extra,
    mason,
    startscreen,
    gitsigns,
    neorg,
    diag
}
