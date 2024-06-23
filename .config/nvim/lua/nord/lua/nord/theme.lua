local nord = require("nord.colors")
local theme = {}

local italic = vim.g.nord_italic == false and nord.none or "italic"
local italic_undercurl = vim.g.nord_italic == false and "undercurl" or "italic,undercurl"
local undercurl = "undercurl"
local bold = vim.g.nord_bold == false and nord.none or "bold"
local reverse_bold = vim.g.nord_bold == false and "reverse" or "reverse,bold"
local bold_underline = vim.g.nord_bold == false and "underline" or "bold,underline"
local bold_italic;
if vim.g.nord_bold == false then
	bold_italic = vim.g.nord_italic == false and nord.none or "italic"
elseif vim.g.nord_italic == false then
	bold_italic = "bold"
else
	bold_italic = "bold,italic"
end

theme.loadSyntax = function()
	-- Syntax highlight groups
	return {
		Type = { fg = nord.nord15_gui }, -- int, long, char, etc.
		StorageClass = { fg = nord.nord9_gui }, -- static, register, volatile, etc.
		Structure = { fg = nord.nord9_gui }, -- struct, union, enum, etc.
		Constant = { fg = nord.nord13_gui }, -- any constant
		Character = { fg = nord.nord14_gui }, -- any character constant: 'c', '\n'
		Number = { fg = nord.nord15_gui }, -- a number constant: 5
		Boolean = { fg = nord.nord13_gui }, -- a boolean constant: TRUE, false
		Float = { fg = nord.nord15_gui }, -- a floating point constant: 2.3e10
		Statement = { fg = nord.nord6_gui }, -- any statement
		Label = { fg = nord.nord13_gui }, -- case, default, etc.
		Operator = { fg = nord.nord9_gui }, -- sizeof", "+", "*", etc.
		Exception = { fg = nord.nord9_gui }, -- try, catch, throw
		PreProc = { fg = nord.nord9_gui }, -- generic Preprocessor
		Include = { fg = nord.nord9_gui }, -- preprocessor #include
		Define = { fg = nord.nord9_gui }, -- preprocessor #define
		Macro = { fg = nord.nord8_gui }, -- same as Define
		Typedef = { fg = nord.nord9_gui }, -- A typedef
		PreCondit = { fg = nord.nord13_gui }, -- preprocessor #if, #else, #endif, etc.
		Special = { fg = nord.nord4_gui }, -- any special symbol
		SpecialChar = { fg = nord.nord13_gui }, -- special character in a constant
		Tag = { fg = nord.nord4_gui }, -- you can use CTRL-] on this
		Delimiter = { fg = nord.nord6_gui }, -- character that needs attention like , or .
		SpecialComment = { fg = nord.nord8_gui, style=italic}, -- special things inside a comment
		Debug = { fg = nord.nord11_gui }, -- debugging statements
		Underlined = { fg = nord.nord10_gui, bg = nord.none, style = "underline" }, -- text that stands out, HTML links
		Ignore = { fg = nord.nord1_gui }, -- left blank, hidden
		Todo = { fg = nord.nord13_gui, bg = nord.none, style = bold_italic }, -- anything that needs extra attention; mostly the keywords TODO FIXME and XXX
		Conceal = { fg = nord.none, bg = nord.nord0_gui },
		htmlLink = { fg = nord.nord10_gui, style = "italic,underline" },
		markdownH1Delimiter = { fg = nord.nord8_gui },
		markdownH2Delimiter = { fg = nord.nord11_gui },
		markdownH3Delimiter = { fg = nord.nord14_gui },
		htmlH1 = { fg = nord.nord8_gui, style = bold },
		htmlH2 = { fg = nord.nord11_gui, style = bold },
		htmlH3 = { fg = nord.nord14_gui, style = bold },
		htmlH4 = { fg = nord.nord15_gui, style = bold },
		htmlH5 = { fg = nord.nord9_gui, style = bold },
		markdownH1 = { fg = nord.nord8_gui, style = bold },
		markdownH2 = { fg = nord.nord11_gui, style = bold },
		markdownH3 = { fg = nord.nord14_gui, style = bold },
		Error = { fg = nord.nord11_gui, bg = nord.none, style = bold_underline }, -- any erroneous construct with bold
		Comment = { fg = nord.nord3_gui_bright, style = italic }, -- italic comments
		Conditional = { fg = nord.nord10_gui}, -- italic if, then, else, endif, switch, etc.
		Function = { fg = nord.nord8_gui}, -- italic funtion names
		Identifier = { fg = nord.nord9_gui}, -- any variable name
		Keyword = { fg = nord.nord6_gui}, -- italic for, do, while, etc.
		Repeat = { fg = nord.nord13_gui}, -- italic any other keyword
		String = { fg = nord.nord14_gui}, -- any string
	}
end

theme.loadEditor = function()
	-- Editor highlight groups

	local editor = {
		NormalFloat = { fg = nord.nord6_gui, bg=nord.nord0_gui }, -- normal text and background color
		VertSplit = { fg = nord.nord2_gui },
		FloatBorder = { fg = nord.nord3_gui, bg = nord.none }, -- normal text and background color
        LspInfoBorder = {link = "FloatBorder"},
		WinSeparator = {link = "VertSplit"},
		ColorColumn = { fg = nord.none, bg = nord.nord1_gui }, -- used for the columns set with 'colorcolumn'
		Conceal = { fg = nord.nord1_gui }, -- placeholder characters substituted for concealed text (see 'conceallevel')
		Cursor = { fg = nord.nord4_gui, bg = nord.none, style = "reverse" }, -- the character under the cursor
		CursorIM = { fg = nord.nord5_gui, bg = nord.none, style = "reverse" }, -- like Cursor, but used when in IME mode
		Directory = { fg = nord.nord7_gui, bg = nord.none }, -- directory names (and other special names in listings)
		EndOfBuffer = { fg = nord.nord1_gui },
		ErrorMsg = { fg = nord.none },
		Folded = { fg = nord.nord3_gui_bright, bg = nord.none},
		FoldColumn = { fg = nord.nord3_gui, style = bold },
		LineNr = { fg = nord.nord3_gui_bright },
		CursorLineNr = { fg = nord.nord4_gui },
		MatchParen = { fg = nord.nord15_gui, bg = nord.nord2_gui, style = bold },
		ModeMsg = { fg = nord.nord4_gui },
		MoreMsg = { fg = nord.nord4_gui },
		NonText = { fg = nord.nord1_gui },
		Pmenu = { fg = nord.nord6_gui, bg = nord.nord1_gui },
		PmenuSel = { fg = nord.nord0_gui, bg = nord.nord7_gui },
		PmenuSbar = { fg = nord.nord4_gui, bg = nord.nord2_gui },
		PmenuThumb = { fg = nord.nord4_gui, bg = nord.nord4_gui },
		Question = { fg = nord.nord14_gui },
		QuickFixLine = { fg = nord.nord4_gui, bg = nord.none, style = "reverse" },
		qfLineNr = { fg = nord.nord4_gui, bg = nord.none, style = "reverse" },
		Search = { bg = nord.nord1_gui },
        CurSearch = { bg = nord.nord3_gui},
		IncSearch = { bg = nord.nord3_gui },
		Substitute = { fg = nord.nord3_gui, bg = nord.nord13_gui },
		IncrementalRename = { fg = nord.nord7_gui, bg = nord.nord3_gui },
		SpecialKey = { fg = nord.nord9_gui },
		SpellBad = { fg = nord.nord12_gui, bg = nord.none, style = undercurl },
		SpellCap = { fg = nord.nord7_gui, bg = nord.none, style = undercurl },
		SpellLocal = { fg = nord.nord8_gui, bg = nord.none, style = undercurl },
		SpellRare = { fg = nord.nord15_gui, bg = nord.none, style = undercurl },
		StatusLine = { fg = nord.nord0_gui, bg = nord.nord0_gui },
		StatusLineNC = { fg = nord.nord4_gui, bg = nord.nord1_gui },
		StatusLineTerm = { fg = nord.nord4_gui, bg = nord.nord2_gui },
		StatusLineTermNC = { fg = nord.nord4_gui, bg = nord.nord1_gui },
		TabLineFill = { fg = nord.nord4_gui, bg = nord.none },
		TablineSel = { fg = nord.nord1_gui, bg = nord.nord9_gui },
		Tabline = { fg = nord.nord4_gui, bg = nord.nord1_gui },
		Title = { fg = nord.nord7_gui, bg = nord.none, style = bold },
		Visual = { fg = nord.none, bg = nord.nord2_gui },
		VisualNOS = { fg = nord.none, bg = nord.nord2_gui },
		WarningMsg = { fg = nord.nord15_gui },
		WildMenu = { fg = nord.nord12_gui, bg = nord.none, style = bold },
		CursorColumn = { fg = nord.none, bg = nord.cursorlinefg },
		CursorLine = { fg = nord.none, bg = nord.cursorlinefg },
		ToolbarLine = { fg = nord.nord4_gui, bg = nord.nord1_gui },
		ToolbarButton = { fg = nord.nord4_gui, bg = nord.none, style = bold },
		NormalMode = { fg = nord.nord4_gui, bg = nord.none, style = "reverse" },
		InsertMode = { fg = nord.nord14_gui, bg = nord.none, style = "reverse" },
		ReplacelMode = { fg = nord.nord11_gui, bg = nord.none, style = "reverse" },
		VisualMode = { fg = nord.nord9_gui, bg = nord.none, style = "reverse" },
		CommandMode = { fg = nord.nord4_gui, bg = nord.none, style = "reverse" },
		Warnings = { fg = nord.nord15_gui },

		healthError = { fg = nord.nord11_gui },
		healthSuccess = { fg = nord.nord14_gui },
		healthWarning = { fg = nord.nord15_gui },

		-- dashboard
		DashboardShortCut = { fg = nord.nord7_gui },
		DashboardHeader = { fg = nord.nord9_gui },
		DashboardCenter = { fg = nord.nord8_gui },
		DashboardFooter = { fg = nord.nord14_gui, style = italic },

		-- Barbar
		BufferTabpageFill = { bg = nord.nord0_gui },

		BufferCurrent = { bg = nord.nord1_gui },
		BufferCurrentMod = { bg = nord.nord1_gui, fg = nord.nord15_gui },
		BufferCurrentIcon = { bg = nord.nord1_gui },
		BufferCurrentSign = { bg = nord.nord1_gui },
		BufferCurrentIndex = { bg = nord.nord1_gui },
		BufferCurrentTarget = { bg = nord.nord1_gui, fg = nord.nord11_gui },

		BufferInactive = { bg = nord.nord0_gui, fg = nord.nord3_gui },
		BufferInactiveMod = { bg = nord.nord0_gui, fg = nord.nord15_gui },
		BufferInactiveIcon = { bg = nord.nord0_gui, fg = nord.nord3_gui },
		BufferInactiveSign = { bg = nord.nord0_gui, fg = nord.nord3_gui },
		BufferInactiveIndex = { bg = nord.nord0_gui, fg = nord.nord3_gui },
		BufferInactiveTarget = { bg = nord.nord0_gui, fg = nord.nord11_gui },

		BufferVisible = { bg = nord.nord2_gui },
		BufferVisibleMod = { bg = nord.nord2_gui, fg = nord.nord15_gui },
		BufferVisibleIcon = { bg = nord.nord2_gui },
		BufferVisibleSign = { bg = nord.nord2_gui },
		BufferVisibleIndex = { bg = nord.nord2_gui },
		BufferVisibleTarget = { bg = nord.nord2_gui, fg = nord.nord11_gui },

		-- leap.nvim
		LeapMatch = { style = "underline,nocombine", fg = nord.nord13_gui },
		LeapLabelPrimary = { style = "nocombine", fg = nord.nord0_gui, bg = nord.nord13_gui },
		LeapLabelSecondary = { style = "nocombine", fg = nord.nord0_gui, bg = nord.nord15_gui },

	}

	-- Options:

	--Set transparent background
	if vim.g.nord_disable_background then
		editor.Normal = { fg = nord.nord6_gui, bg = nord.none } -- normal text and background color
		editor.SignColumn = { fg = nord.nord4_gui, bg = nord.none }
	else
		editor.Normal = { fg = nord.nord4_gui, bg = nord.nord0_gui } -- normal text and background color
		editor.SignColumn = { fg = nord.nord4_gui, bg = nord.nord0_gui }
	end

	-- Remove window split borders

	-- if vim.g.nord_uniform_diff_background then
	-- 	editor.DiffAdd = { fg = nord.nord14_gui, bg = nord.nord1_gui } -- diff mode: Added line
	-- 	editor.DiffChange = { fg = nord.nord13_gui, bg = nord.nord1_gui } -- diff mode: Changed line
	-- 	editor.DiffDelete = { fg = nord.nord11_gui, bg = nord.nord1_gui } -- diff mode: Deleted line
	-- 	editor.DiffText = { fg = nord.nord15_gui, bg = nord.nord1_gui } -- diff mode: Changed text within a changed line
	-- else
	-- 	editor.DiffAdd = { fg = nord.nord14_gui, bg = nord.none, style = "reverse" } -- diff mode: Added line
	-- 	editor.DiffChange = { fg = nord.nord13_gui, bg = nord.none, style = "reverse" } -- diff mode: Changed line
	-- 	editor.DiffDelete = { fg = nord.nord11_gui, bg = nord.none, style = "reverse" } -- diff mode: Deleted line
	-- 	editor.DiffText = { fg = nord.nord15_gui, bg = nord.none, style = "reverse" } -- diff mode: Changed text within a changed line
	-- end
    --
    editor.DiffAdd      = { fg = nord.nord14_gui}
    editor.DiffChange   = { fg = nord.nord13_gui}
    editor.DiffDelete   = { fg = nord.nord11_gui}
    editor.DiffText     = { fg = nord.nord15_gui}

	return editor
end

theme.loadTerminal = function()
	vim.g.terminal_color_0 = nord.nord1_gui
	vim.g.terminal_color_1 = nord.nord11_gui
	vim.g.terminal_color_2 = nord.nord14_gui
	vim.g.terminal_color_3 = nord.nord13_gui
	vim.g.terminal_color_4 = nord.nord9_gui
	vim.g.terminal_color_5 = nord.nord15_gui
	vim.g.terminal_color_6 = nord.nord7_gui
	vim.g.terminal_color_7 = nord.nord5_gui
	vim.g.terminal_color_8 = nord.nord3_gui
	vim.g.terminal_color_9 = nord.nord11_gui
	vim.g.terminal_color_10 = nord.nord14_gui
	vim.g.terminal_color_11 = nord.nord13_gui
	vim.g.terminal_color_12 = nord.nord9_gui
	vim.g.terminal_color_13 = nord.nord15_gui
	vim.g.terminal_color_14 = nord.nord8_gui
	vim.g.terminal_color_15 = nord.nord6_gui
end

theme.loadTreeSitter = function()
	-- TreeSitter highlight groups

	local treesitter = {
		TSConstructor = { fg = nord.nord9_gui }, -- For constructor calls and definitions: `= { }` in Lua, and Java constructors.
		TSConstant = { fg = nord.nord13_gui }, -- For constants
		TSFloat = { fg = nord.nord15_gui }, -- For floats
		TSNumber = { fg = nord.nord15_gui }, -- For all number
		TSAttribute = { fg = nord.nord15_gui }, -- (unstable) TODO: docs
		TSError = { fg = nord.nord11_gui }, -- For syntax/parser errors.
		TSException = { fg = nord.nord12_gui }, -- For exception related keywords.
		TSFuncMacro = { fg = nord.nord7_gui }, -- For macro defined fuctions (calls and definitions): each `macro_rules` in Rust.
		TSInclude = { fg = nord.nord9_gui }, -- For includes: `#include` in C, `use` or `extern crate` in Rust, or `require` in Lua.
		TSLabel = { fg = nord.nord15_gui }, -- For labels: `label:` in C and `:label:` in Lua.
		TSOperator = { fg = nord.nord9_gui }, -- For any operator: `+`, but also `->` and `*` in C.
		TSParameter = { fg = nord.nord10_gui }, -- For parameters of a function.
		TSParameterReference = { fg = nord.nord10_gui }, -- For references to parameters of a function.
		TSPunctDelimiter = { fg = nord.nord8_gui }, -- For delimiters ie: `.`
		TSPunctBracket = { fg = nord.nord8_gui }, -- For brackets and parens.
		TSPunctSpecial = { fg = nord.nord8_gui }, -- For special punctutation that does not fall in the catagories before.
		TSSymbol = { fg = nord.nord15_gui }, -- For identifiers referring to symbols or atoms.
		TSType = { fg = nord.nord9_gui }, -- For types.
		TSTypeBuiltin = { fg = nord.nord9_gui }, -- For builtin types.
		TSTag = { fg = nord.nord4_gui }, -- Tags like html tag names.
		TSTagDelimiter = { fg = nord.nord15_gui }, -- Tag delimiter like `<` `>` `/`
		TSText = { fg = nord.nord4_gui }, -- For strings considenord11_gui text in a markup language.
		TSTextReference = { fg = nord.nord15_gui }, -- FIXME
		TSEmphasis = { fg = nord.nord13_gui }, -- For text to be represented with emphasis.
		TSUnderline = { fg = nord.nord4_gui, bg = nord.none, style = "underline" }, -- For text to be represented with an underline.
		TSLiteral = { fg = nord.nord4_gui }, -- Literal text.
		TSURI = { fg = nord.nord10_gui }, -- Any URI like a link or email.
		TSAnnotation = { fg = nord.nord11_gui }, -- For C++/Dart attributes, annotations that can be attached to the code to denote some kind of meta information.
		["@constructor"] = { fg = nord.nord9_gui },
		["@constant"] = { fg = nord.nord13_gui },
		["@float"] = { fg = nord.nord15_gui },
		["@number"] = { fg = nord.nord15_gui },
		["@attribute"] = { fg = nord.nord15_gui },
		["@error"] = { fg = nord.nord11_gui },
		["@exception"] = { fg = nord.nord15_gui },
		["@funtion.macro"] = { fg = nord.nord7_gui },
		["@include"] = { fg = nord.nord9_gui },
		["@label"] = { fg = nord.nord15_gui },
		["@operator"] = { fg = nord.nord9_gui },
		["@parameter"] = { fg = nord.nord10_gui },
		["@punctuation.delimiter"] = { fg = nord.nord3_gui },
		["@punctuation.bracket"] = { fg = nord.nord8_gui },
		["@punctuation.special"] = { fg = nord.nord8_gui },
		["@symbol"] = { fg = nord.nord15_gui },
		["@type"] = { fg = nord.nord15_gui },
		["@type.builtin"] = { fg = nord.nord9_gui },
		["@tag"] = { fg = nord.nord4_gui },
		["@tag.delimiter"] = { fg = nord.nord15_gui },
		["@text"] = { fg = nord.nord4_gui },
		["@text.reference"] = { fg = nord.nord15_gui },
		["@text.emphasis"] = { fg = nord.nord4_gui, style = "italic" },
		["@text.underline"] = { fg = nord.nord4_gui, bg = nord.none, style = "underline" },
		["@text.literal"] = { fg = nord.nord4_gui },
		["@text.uri"] = { fg = nord.nord10_gui },
		["@text.strike"] = { fg = nord.nord4_gui, style = "strikethrough" },
        ["@markup.italic.markdown_inline"] = {style = italic},
        ["@markup.strong.markdown_inline"] = {style = bold},

		-- @todo Missing highlights
		-- @function.call
		-- @method.call
		-- @type.qualifier
		-- @text.math (e.g. for LaTeX math environments)
		-- @text.environment (e.g. for text environments of markup languages)
		-- @text.environment.name (e.g. for the name/the string indicating the type of text environment)
		-- @text.note
		-- @text.warning
		-- @text.danger
		-- @tag.attribute
		-- @string.special
	}

	treesitter.TSVariableBuiltin = { fg = nord.nord9_gui}
	treesitter.TSBoolean = { fg = nord.nord14_gui }
	treesitter.TSConstBuiltin = { fg = nord.nord12_gui}
	treesitter.TSConstMacro = { fg = nord.nord12_gui}
	treesitter.TSVariable = { fg = nord.nord6_gui }
	treesitter.TSTitle = { fg = nord.nord10_gui, bg = nord.none, style = bold }
	treesitter["@variable"] = { fg = nord.nord9_gui}
	treesitter["@lsp.mod.readonly"] = {}
	treesitter["@variable.builtin"] = { fg = nord.nord6_gui}
	treesitter["@variable.global"] = { fg = nord.nord6_gui}
	treesitter["@boolean"] = { fg = nord.nord7_gui}
	treesitter["@constant.builtin"] = { fg = nord.nord7_gui}
	treesitter["@constant.macro"] = { fg = nord.nord7_gui}
	treesitter["@text.title"] = { fg = nord.nord10_gui, bg = nord.none}
	treesitter["@text.strong"] = { fg = nord.nord6_gui, bg = nord.none, style = "bold"}
	-- Comments
	treesitter.TSComment = { fg = nord.nord3_gui_bright, style = italic }
	-- Conditionals
	treesitter.TSConditional = { fg = nord.nord9_gui } -- For keywords related to conditionnals.
	-- Function names
	treesitter.TSMethod = { fg = nord.nord7_gui } -- For method calls and definitions.
	treesitter.TSFuncBuiltin = { fg = nord.nord8_gui }
	-- Namespaces and property accessors
	treesitter.TSNamespace = { fg = nord.nord4_gui } -- For identifiers referring to modules and namespaces.
	treesitter.TSField = { fg = nord.nord4_gui } -- For fields.
	treesitter.TSProperty = { fg = nord.nord10_gui } -- Same as `TSField`, but when accessing, not declaring.
	-- Language keywords
	treesitter.TSKeyword = { fg = nord.nord9_gui } -- For keywords that don't fall in other categories.
	treesitter.TSKeywordFunction = { fg = nord.nord8_gui }
	treesitter.TSKeywordReturn = { fg = nord.nord8_gui }
	treesitter.TSKeywordOperator = { fg = nord.nord8_gui }
	treesitter.TSRepeat = { fg = nord.nord9_gui } -- For keywords related to loops.
	-- Strings
	treesitter.TSString = { fg = nord.nord14_gui } -- For strings.
	treesitter.TSStringRegex = { fg = nord.nord12_gui } -- For regexes.
	treesitter.TSStringEscape = { fg = nord.nord15_gui } -- For escape characters within a string.
	treesitter.TSCharacter = { fg = nord.nord14_gui } -- For characters.

	treesitter["@comment"] = { fg = nord.nord3_gui_bright, style = italic }
	treesitter["@conditional"] = { fg = nord.nord9_gui }
	treesitter["@keyword.conditional"] = { fg = nord.nord9_gui }
	treesitter["@function"] = { fg = nord.nord8_gui }
	treesitter["@method"] = { fg = nord.nord8_gui }
	treesitter["@function.builtin"] = { fg = nord.nord8_gui }
	treesitter["@namespace"] = { fg = nord.nord4_gui }
	treesitter["@field"] = { fg = nord.nord4_gui }
	treesitter["@property"] = { fg = nord.nord10_gui }
	treesitter["@keyword"] = { fg = nord.nord9_gui }
	treesitter["@keyword.function"] = { fg = nord.nord8_gui }
	treesitter["@keyword.return"] = { fg = nord.nord9_gui }
	treesitter["@keyword.operator"] = { fg = nord.nord8_gui }
	treesitter["@repeat"] = { fg = nord.nord9_gui }
	treesitter["@string"] = { fg = nord.nord14_gui }
	treesitter["@string.regex"] = { fg = nord.nord12_gui }
	treesitter["@string.escape"] = { fg = nord.nord13_gui }
	treesitter["@character"] = { fg = nord.nord14_gui }

	return treesitter
end

theme.loadFiletypes = function()
	-- Filetype-specific highlight groups

	local ft = {
		-- yaml
		yamlBlockMappingKey = { fg = nord.nord7_gui },
		yamlBool = { link = "Boolean" },
		yamlDocumentStart = { link = "Keyword" },
		yamlTSField = { fg = nord.nord7_gui },
		yamlTSString = { fg = nord.nord4_gui },
		yamlTSPunctSpecial = { link = "Keyword" },
		yamlKey = { fg = nord.nord7_gui }, -- stephpy/vim-yaml
	}

	return ft
end

theme.loadLSP = function()
	-- Lsp highlight groups

	local lsp = {
		LspDiagnosticsDefaultError = { fg = nord.nord11_gui }, -- used for "Error" diagnostic virtual text
		LspDiagnosticsSignError = { fg = nord.nord11_gui }, -- used for "Error" diagnostic signs in sign column
		LspDiagnosticsFloatingError = { fg = nord.nord11_gui, bg=nord.none }, -- used for "Error" diagnostic messages in the diagnostics float
		LspDiagnosticsVirtualTextError = { fg = nord.nord11_gui }, -- Virtual text "Error"
		LspDiagnosticsUnderlineError = { style = "undercurl", sp = nord.nord11_gui }, -- used to underline "Error" diagnostics.
		LspDiagnosticsDefaultWarning = { fg = nord.nord12_gui }, -- used for "Warning" diagnostic signs in sign column
		LspDiagnosticsSignWarning = { fg = nord.nord12_gui }, -- used for "Warning" diagnostic signs in sign column
		LspDiagnosticsFloatingWarning = { fg = nord.nord12_gui, bg=nord.none }, -- used for "Warning" diagnostic messages in the diagnostics float
		LspDiagnosticsVirtualTextWarning = { fg = nord.nord12_gui }, -- Virtual text "Warning"
		LspDiagnosticsUnderlineWarning = { style = "undercurl", sp = nord.nord12_gui }, -- used to underline "Warning" diagnostics.
		LspDiagnosticsDefaultInformation = { fg = nord.nord10_gui }, -- used for "Information" diagnostic virtual text
		LspDiagnosticsSignInformation = { fg = nord.nord10_gui }, -- used for "Information" diagnostic signs in sign column
		LspDiagnosticsFloatingInformation = { fg = nord.nord10_gui, bg=nord.none }, -- used for "Information" diagnostic messages in the diagnostics float
		LspDiagnosticsVirtualTextInformation = { fg = nord.nord10_gui }, -- Virtual text "Information"
		LspStaticMethod = { fg = nord.nord15_gui }, -- Virtual text "Information"
		LspDiagnosticsUnderlineInformation = { style = "undercurl", sp = nord.nord10_gui }, -- used to underline "Information" diagnostics.
		LspDiagnosticsDefaultHint = { fg = nord.nord9_gui }, -- used for "Hint" diagnostic virtual text
		LspDiagnosticsSignHint = { fg = nord.nord9_gui }, -- used for "Hint" diagnostic signs in sign column
		LspDiagnosticsFloatingHint = { fg = nord.nord9_gui}, -- used for "Hint" diagnostic messages in the diagnostics float
		LspDiagnosticsVirtualTextHint = { fg = nord.nord9_gui }, -- Virtual text "Hint"
		LspDiagnosticsUnderlineHint = { style = "undercurl", sp = nord.nord10_gui }, -- used to underline "Hint" diagnostics.
		LspReferenceText = { fg = nord.nord4_gui, bg = nord.nord1_gui }, -- used for highlighting "text" references
		LspReferenceRead = { fg = nord.nord4_gui, bg = nord.nord1_gui }, -- used for highlighting "read" references
		LspReferenceWrite = { fg = nord.nord4_gui, bg = nord.nord1_gui }, -- used for highlighting "write" references

		DiagnosticError = { link = "LspDiagnosticsDefaultError" },
		DiagnosticWarn = { link = "LspDiagnosticsDefaultWarning" },
		DiagnosticInfo = { link = "LspDiagnosticsDefaultInformation" },
		DiagnosticHint = { link = "LspDiagnosticsDefaultHint" },
		DiagnosticVirtualTextWarn = { link = "LspDiagnosticsVirtualTextWarning" },
		DiagnosticUnderlineWarn = { link = "LspDiagnosticsUnderlineWarning" },
		DiagnosticFloatingWarn = { link = "LspDiagnosticsFloatingWarning" },
		DiagnosticSignWarn = { link = "LspDiagnosticsSignWarning" },
		DiagnosticVirtualTextError = { link = "LspDiagnosticsVirtualTextError" },
		DiagnosticUnderlineError = { link = "LspDiagnosticsUnderlineError" },
		DiagnosticFloatingError = { link = "LspDiagnosticsFloatingError" },
		DiagnosticSignError = { link = "LspDiagnosticsSignError" },
		DiagnosticVirtualTextInfo = { link = "LspDiagnosticsVirtualTextInformation" },
		DiagnosticUnderlineInfo = { link = "LspDiagnosticsUnderlineInformation" },
		DiagnosticFloatingInfo = { link = "LspDiagnosticsFloatingInformation" },
		DiagnosticSignInfo = { link = "LspDiagnosticsSignInformation" },
		DiagnosticVirtualTextHint = { link = "LspDiagnosticsVirtualTextHint" },
		DiagnosticUnderlineHint = { link = "LspDiagnosticsUnderlineHint" },
		DiagnosticFloatingHint = { link = "LspDiagnosticsFloatingHint" },
		DiagnosticSignHint = { link = "LspDiagnosticsSignHint" },

        DiagnosticsSignError = {fg = nord.nord11_gui, style = "bold"},
        DiagnosticsSignWarn = {fg = nord.nord12_gui, style = "bold"},
        DiagnosticsSignInfo = {fg = nord.nord10_gui, style = "bold"},
        DiagnosticsSignHint = {fg = nord.nord9_gui, style = "bold"},
	}

	return lsp
end

theme.loadPlugins = function()
	-- Plugins highlight groups

	local plugins = {

        -- oil
        OilLink = {fg = nord.nord10_gui, style = "bold"},
        OilDir = {fg = nord.nord7_gui, style = "bold"},
        OilLinkTarget = {fg = nord.nord10_gui, style = "italic"},
        OilSocket = {fg = nord.nord15_gui},

        OilRead   = {fg = nord.nord13_gui},
        OilWrite  = {fg = nord.nord12_gui},
        OilExec   = {fg = nord.nord14_gui},
        OilSetuid = {fg = nord.nord11_gui, style = "bold"},
        OilSticky = {fg = nord.nord10_gui, style = "bold"},
        OilNoPerm = {fg = nord.nord3_gui},

        OilDelete = {fg = nord.nord11_gui, style = "bold"},
        OilCreate = {fg = nord.nord14_gui},
        OilMove   = {fg = nord.nord12_gui},
        OilCopy   = {fg = nord.nord13_gui},
        OilChange = {fg = nord.nord15_gui},


        OilGitStatusIndexIgnored = {fg = nord.nord3_gui},
        OilGitStatusWorkingTreeIgnored = {link = "OilGitStatusIndexIgnored"},

        OilGitStatusIndexUntracked = {link = "OilGitStatusIndexIgnored"},
        OilGitStatusWorkingTreeUntracked = {link = "OilGitStatusIndexIgnored"},

        OilGitStatusIndexAdded = {fg = nord.nord14_gui},
        OilGitStatusWorkingTreeAdded = {link = "OilGitStatusIndexAdded"},

        OilGitStatusIndexCopied = {fg = nord.nord13_gui},
        OilGitStatusWorkingTreeCopied = {link = "OilGitStatusIndexCopied"},

        OilGitStatusIndexDeleted = {fg = nord.nord11_gui},
        OilGitStatusWorkingTreeDeleted = {link = "OilGitStatusIndexDeleted"},

        OilGitStatusIndexModified = {fg = nord.nord15_gui},
        OilGitStatusWorkingTreeModified = {link = "OilGitStatusIndexModified"},

        OilGitStatusIndexRenamed = {fg = nord.nord9_gui},
        OilGitStatusWorkingTreeRenamed = {link = "OilGitStatusIndexRenamed"},

        OilGitStatusIndexTypeChanged = {fg = nord.nord12_gui},
        OilGitStatusWorkingTreeTypeChanged = {link = "OilGitStatusIndexTypeChanged"},

        OilGitStatusIndexUnmerged = {fg = nord.nord4_gui},
        OilGitStatusWorkingTreeUnmerged = {link = "OilGitStatusIndexUnmerged"},

        -- startup
        StartScreenShortcutGeneric = {fg = nord.nord15_gui},
        StartScreenShortcutFiles = {fg = nord.nord7_gui},
        StartScreenShortcutSearch = {fg = nord.nord12_gui},
        StartScreenShortcutGrep = {fg = nord.nord13_gui},
        StartScreenShortcutDir = {fg = nord.nord7_gui},
        StartScreenShortcutHistory = {fg = nord.nord10_gui},
        StartScreenShortcutLazy = {fg = nord.nord14_gui},
        StartScreenShortcutQuit = {fg = nord.nord11_gui},

        StartScreenHistory = {fg = nord.nord10_gui},
        StartScreenTitle1 = {fg = nord.nord11_gui},
        StartScreenTitle2 = {fg = nord.nord12_gui},
        StartScreenTitle3 = {fg = nord.nord13_gui},
        StartScreenTitle4 = {fg = nord.nord14_gui},
        StartScreenTitle5 = {fg = nord.nord7_gui},
        StartScreenTitle6 = {fg = nord.nord9_gui},
        StartScreenTitle7 = {fg = nord.nord10_gui},
        StartScreenTitle8 = {fg = nord.nord15_gui},

        -- mason
        MasonHeader = {fg = nord.nord0_gui, bg = nord.nord7_gui},
        MasonHeaderSecondary = {fg = nord.nord0_gui, bg = nord.nord7_gui},

        MasonHighlight = {fg = nord.nord15_gui},
        MasonHighlightBlock = {fg = nord.nord0_gui, bg = nord.nord7_gui},
        MasonHighlightBlockBold = {link = "MasonHighlightBlock"},

        MasonHighlightSecondary = {link = "MasonHighlight"},
        MasonHighlightSecondaryBlock = {link = "MasonHighlightBlock"},
        MasonHighlightSecondaryBlockBold = {link = "MasonHighlightBlockBold"},

        MasonMuted = {fg = nord.nord3_gui},
        MasonMutedBlock = {bg = nord.nord3_gui},
        MasonMutedBlockBold = {link = "MasonMutedBlock"},

        -- noice
        NoiceCmdLineIcon = {fg = nord.nord3_gui},
        NoiceCmdLineIconLua = {fg = nord.nord10_gui},
        NoiceCmdLineIconSearch = {fg = nord.nord15_gui},

		-- LspTrouble
		LspTroubleText = { fg = nord.nord4_gui },
		LspTroubleCount = { fg = nord.nord9_gui, bg = nord.nord10_gui },
		LspTroubleNormal = { fg = nord.nord4_gui, bg = nord.sidebar },

		-- Diff
		diffAdded = { fg = nord.nord14_gui },
		diffRemoved = { fg = nord.nord11_gui },
		diffChanged = { fg = nord.nord15_gui },
		diffOldFile = { fg = nord.nord13_gui },
		diffNewFile = { fg = nord.nord12_gui },
		diffFile = { fg = nord.nord7_gui },
		diffLine = { fg = nord.nord3_gui },
		diffIndexLine = { fg = nord.nord9_gui },

		-- Neogit
		NeogitBranch = { fg = nord.nord10_gui },
		NeogitRemote = { fg = nord.nord9_gui },
		NeogitHunkHeader = { fg = nord.nord8_gui },
		NeogitHunkHeaderHighlight = { fg = nord.nord8_gui, bg = nord.nord1_gui },
		NeogitDiffContextHighlight = { bg = nord.nord1_gui },
		NeogitDiffDeleteHighlight = { fg = nord.nord11_gui, style = "reverse" },
		NeogitDiffAddHighlight = { fg = nord.nord14_gui, style = "reverse" },

		-- GitGutter
		GitGutterAdd = { fg = nord.nord14_gui }, -- diff mode: Added line |diff.txt|
		GitGutterChange = { fg = nord.nord13_gui }, -- diff mode: Changed line |diff.txt|
		GitGutterDelete = { fg = nord.nord11_gui }, -- diff mode: Deleted line |diff.txt|

		-- GitSigns
		GitSignsAdd = { fg = nord.nord3_gui }, -- diff mode: Added line |diff.txt|
		GitSignsAddNr = { fg = nord.nord3_gui }, -- diff mode: Added line |diff.txt|
		GitSignsAddLn = { fg = nord.nord3_gui }, -- diff mode: Added line |diff.txt|
		GitSignsChange = { fg = nord.nord15_gui }, -- diff mode: Changed line |diff.txt|
		GitSignsChangeNr = { fg = nord.nord3_gui }, -- diff mode: Changed line |diff.txt|
		GitSignsChangeLn = { fg = nord.nord3_gui }, -- diff mode: Changed line |diff.txt|
		GitSignsDelete = { fg = nord.nord11_gui }, -- diff mode: Deleted line |diff.txt|
		GitSignsDeleteNr = { fg = nord.nord3_gui }, -- diff mode: Deleted line |diff.txt|
		GitSignsDeleteLn = { fg = nord.nord3_gui }, -- diff mode: Deleted line |diff.txt|
		GitSignsCurrentLineBlame = { fg = nord.nord3_gui_bright},
        GitSignsAddInline = {fg = nord.nord14_gui, style = italic},
        GitSignsDeleteInline = {fg = nord.nord11_gui, style = italic},
        GitSignsChangeInline = {fg = nord.nord15_gui, style = italic},

        -- GitSignsAdd

		-- Telescope
		TelescopePromptBorder = { fg = nord.nord3_gui },
        TelescopePromptTitle = { fg = nord.nord15_gui },
		TelescopeResultsBorder = { fg = nord.nord3_gui },
		TelescopePreviewBorder = { fg = nord.nord3_gui },
		TelescopeSelection = { bg = nord.nord2_gui },
        TelescopePromptPrefix = {fg = nord.nord15_gui },
        TelescopeSelectionCaret = { bg = nord.nord15_gui, fg = nord.nord15_gui},
		TelescopeMatching = { link = 'Search' },

		LspDiagnosticsError = { fg = nord.nord12_gui },
		LspDiagnosticsWarning = { fg = nord.nord15_gui },
		LspDiagnosticsInformation = { fg = nord.nord10_gui },
		LspDiagnosticsHint = { fg = nord.nord9_gui },

		-- WhichKey
		WhichKey = { fg = nord.nord8_gui, style = bold },
		WhichKeyGroup = { fg = nord.nord5_gui },
		WhichKeyDesc = { fg = nord.nord7_gui, style = italic },
		WhichKeySeperator = { fg = nord.nord9_gui },
		WhichKeyFloating = { bg = nord.nord1_gui },
		WhichKeyFloat = { bg = nord.nord1_gui },
		WhichKeyValue = { fg = nord.nord7_gui },

		-- LspSaga
		DiagnosticError = { fg = nord.nord12_gui },
		DiagnosticWarning = { fg = nord.nord15_gui },
		DiagnosticInformation = { fg = nord.nord10_gui },
		DiagnosticHint = { fg = nord.nord9_gui },
		DiagnosticTruncateLine = { fg = nord.nord4_gui },
		LspFloatWinBorder = { fg = nord.nord4_gui, bg = nord.float },
		LspSagaDefPreviewBorder = { fg = nord.nord4_gui, bg = nord.float },
		DefinitionIcon = { fg = nord.nord7_gui },
		TargetWord = { fg = nord.nord6_gui, style = 'bold' },
		-- LspSaga code action
		LspSagaCodeActionTitle = { link = 'Title' },
		LspSagaCodeActionBorder = { fg = nord.nord4_gui, bg = nord.float },
		LspSagaCodeActionTrunCateLine = { link = 'LspSagaCodeActionBorder' },
		LspSagaCodeActionContent = { fg = nord.nord4_gui },
		-- LspSag finder
		LspSagaLspFinderBorder = { fg = nord.nord4_gui, bg = nord.float },
		LspSagaAutoPreview = { fg = nord.nord4_gui },
		LspSagaFinderSelection = { fg = nord.nord6_gui, bg = nord.nord2_gui },
		TargetFileName = { fg = nord.nord4_gui },
		FinderParam = { fg = nord.nord15_gui, bold = true },
		FinderVirtText = { fg = nord.nord15_gui15 , bg = nord.none },
		DefinitionsIcon = { fg = nord.nord9_gui },
		Definitions = { fg = nord.nord15_gui, bold = true },
		DefinitionCount = { fg = nord.nord10_gui },
		ReferencesIcon = { fg = nord.nord9_gui },
		References = { fg = nord.nord15_gui, bold = true },
		ReferencesCount = { fg = nord.nord10_gui },
		ImplementsIcon = { fg = nord.nord9_gui },
		Implements = { fg = nord.nord15_gui, bold = true },
		ImplementsCount = { fg = nord.nord10_gui },
		-- LspSaga finder spinner
		FinderSpinnerBorder = { fg = nord.nord4_gui, bg = nord.float },
		FinderSpinnerTitle = { link = 'Title' },
		FinderSpinner = { fg = nord.nord8_gui, bold = true },
		FinderPreviewSearch = { link = 'Search' },
		-- LspSaga definition
		DefinitionBorder = { fg = nord.nord4_gui, bg = nord.float },
		DefinitionArrow = { fg = nord.nord8_gui },
		DefinitionSearch = { link = 'Search' },
		DefinitionFile = { fg = nord.nord4_gui, bg = nord.float },
		-- LspSaga hover
		LspSagaHoverBorder = { fg = nord.nord4_gui, bg = nord.float },
		LspSagaHoverTrunCateLine = { link = 'LspSagaHoverBorder' },
		-- Lsp rename
		LspSagaRenameBorder = { fg = nord.nord4_gui, bg = nord.float },
		LspSagaRenameMatch = { fg = nord.nord6_gui, bg = nord.nord9_gui },
		-- Lsp diagnostic
		LspSagaDiagnosticSource = { link = 'Comment' },
		LspSagaDiagnosticError = { link = 'DiagnosticError' },
		LspSagaDiagnosticWarn = { link = 'DiagnosticWarn' },
		LspSagaDiagnosticInfo = { link = 'DiagnosticInfo' },
		LspSagaDiagnosticHint = { link = 'DiagnosticHint' },
		LspSagaErrorTrunCateLine = { link = 'DiagnosticError' },
		LspSagaWarnTrunCateLine = { link = 'DiagnosticWarn' },
		LspSagaInfoTrunCateLine = { link = 'DiagnosticInfo' },
		LspSagaHintTrunCateLine = { link = 'DiagnosticHint' },
		LspSagaDiagnosticBorder = { fg = nord.nord4_gui, bg = nord.float },
		LspSagaDiagnosticHeader = { fg = nord.nord4_gui },
		DiagnosticQuickFix = { fg = nord.nord14_gui, bold = true },
		DiagnosticMap = { fg = nord.nord15_gui },
		DiagnosticLineCol = { fg = nord.nord4_gui },
		LspSagaDiagnosticTruncateLine = { link = 'LspSagaDiagnosticBorder' },
		ColInLineDiagnostic = { link = 'Comment' },
		-- LspSaga signture help
		LspSagaSignatureHelpBorder = { fg = nord.nord4_gui, bg = nord.float },
		LspSagaShTrunCateLine = { link = 'LspSagaSignatureHelpBorder' },
		-- Lspsaga lightbulb
		LspSagaLightBulb = { link = 'DiagnosticSignHint' },
		-- LspSaga shadow
		SagaShadow = { fg = 'black' },
		-- LspSaga float
		LspSagaBorderTitle = { link = 'Title' },
		-- LspSaga Outline
		LSOutlinePreviewBorder = { fg = nord.nord4_gui, bg = nord.float },
		OutlineIndentEvn = { fg = nord.nord15_gui },
		OutlineIndentOdd = { fg = nord.nord12_gui },
		OutlineFoldPrefix = { fg = nord.nord11_gui },
		OutlineDetail = { fg = nord.nord4_gui },
		-- LspSaga all floatwindow
		LspFloatWinNormal = { fg = nord.nord4_gui, bg = nord.float },
		-- Saga End

		-- Sneak
		Sneak = { fg = nord.nord0_gui, bg = nord.nord4_gui },
		SneakScope = { bg = nord.nord1_gui },

		-- Cmp
		CmpItemKind = { fg = nord.nord13_gui },
		CmpItemKindText = { fg = nord.nord3_gui },
		CmpItemKindLatex = { fg = nord.nord14_gui },
        CmpItemKindMethod = {fg = nord.nord15_gui},
        CmpItemKindFunction = {fg = nord.nord7_gui},
        CmpItemKindConstructor = { fg = nord.nord15_gui},
        CmpItemKindField = { fg = nord.nord5_gui},
        CmpItemKindVariable = {fg = nord.nord5_gui},
        CmpItemKindInterface = {fg = nord.nord15_gui},
        CmpItemKindStruct = {link = "CmpItemKindInterface"},
        CmpItemKindClass = {link = "CmpItemKindInterface"},
        CmpItemKindModule = {fg = nord.nord14_gui},
        CmpItemKindFile = {fg = nord.nord13_gui},
        CmpItemKindFolder = {fg = nord.nord9_gui},
        CmpItemKindSnippet = {fg = nord.nord13_gui},
        CmpItemKindConstant = {fg = nord.nord5_gui, style = bold_italic},
        CmpItemKindEnumMember = {fg = nord.nord13_gui},
        CmpItemKindKeyword = {fg = nord.nord5_gui},

		CmpItemAbbrMatch = { fg = nord.nord15_gui, style = bold },
		CmpItemAbbrMatchFuzzy = { fg = nord.nord15_gui, style = bold },
		CmpItemAbbr = { fg = nord.nord6_gui },
		CmpItemMenu = { fg = nord.nord14_gui },

		-- Indent Blankline
		IndentBlanklineChar = { fg = nord.nord3_gui },
		IndentBlanklineContextChar = { fg = nord.nord8_gui },
		IndentBlanklineIndent1 = { fg = nord.nord11_gui, bg = "#4b3d48", bold = true },
		IndentBlanklineIndent2 = { fg = nord.nord12_gui, bg = "#4e454a", bold = true },
		IndentBlanklineIndent3 = { fg = nord.nord13_gui, bg = "#54524f", bold = true },
		IndentBlanklineIndent4 = { fg = nord.nord14_gui, bg = "#454d4f", bold = true },
		IndentBlanklineIndent5 = { fg = nord.nord7_gui, bg = "#46565f", bold = true },
		IndentBlanklineIndent6 = { fg = nord.nord6_gui, bg = "#5e636d", bold = true },

		-- headline
		-- bg = (10 * nord0 + fg) / 11
		Headline1 = { fg = nord.nord11_gui, bg = "#4b3d48", bold = true },
		Headline2 = { fg = nord.nord12_gui, bg = "#4e454a", bold = true },
		Headline3 = { fg = nord.nord13_gui, bg = "#54524f", bold = true },
		Headline4 = { fg = nord.nord14_gui, bg = "#454d4f", bold = true },
		Headline5 = { fg = nord.nord7_gui, bg = "#46565f", bold = true },
		Headline6 = { fg = nord.nord6_gui, bg = "#5e636d", bold = true },

		Quote = { fg = nord.nord2_gui },
		CodeBlock = { bg = nord.nord1_gui },
		Dash = { nord.nord10_gui, bold = true },

		-- Illuminate
		illuminatedWord = { bg = nord.nord3_gui },
		illuminatedCurWord = { bg = nord.nord3_gui },
		IlluminatedWordText = { bg = nord.nord3_gui },
		IlluminatedWordRead = { bg = nord.nord3_gui },
		IlluminatedWordWrite = { bg = nord.nord3_gui },

		-- nvim-dap
		DapBreakpoint = { fg = nord.nord14_gui },
		DapStopped = { fg = nord.nord15_gui },

		-- nvim-dap-ui
		DapUIVariable = { fg = nord.nord4_gui },
		DapUIScope = { fg = nord.nord8_gui },
		DapUIType = { fg = nord.nord9_gui },
		DapUIValue = { fg = nord.nord4_gui },
		DapUIModifiedValue = { fg = nord.nord8_gui },
		DapUIDecoration = { fg = nord.nord8_gui },
		DapUIThread = { fg = nord.nord8_gui },
		DapUIStoppedThread = { fg = nord.nord8_gui },
		DapUIFrameName = { fg = nord.nord4_gui },
		DapUISource = { fg = nord.nord9_gui },
		DapUILineNumber = { fg = nord.nord8_gui },
		DapUIFloatBorder = { fg = nord.nord8_gui },
		DapUIWatchesEmpty = { fg = nord.nord11_gui },
		DapUIWatchesValue = { fg = nord.nord8_gui },
		DapUIWatchesError = { fg = nord.nord11_gui },
		DapUIBreakpointsPath = { fg = nord.nord8_gui },
		DapUIBreakpointsInfo = { fg = nord.nord8_gui },
		DapUIBreakpointsCurrentLine = { fg = nord.nord8_gui },
		DapUIBreakpointsLine = { fg = nord.nord8_gui },
	}
	-- Options:

	-- Disable nvim-tree background
	if vim.g.nord_disable_background then
		plugins.NvimTreeNormal = { fg = nord.nord4_gui, bg = nord.none }
	else
		plugins.NvimTreeNormal = { fg = nord.nord4_gui, bg = nord.sidebar }
	end

	if vim.g.nord_enable_sidebar_background then
		plugins.NvimTreeNormal = { fg = nord.nord4_gui, bg = nord.sidebar }
	else
		plugins.NvimTreeNormal = { fg = nord.nord4_gui, bg = nord.none }
	end

	return plugins
end

return theme
