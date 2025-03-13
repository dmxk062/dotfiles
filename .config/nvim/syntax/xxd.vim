syn match xxdAddress "^[0-9a-f]\+:"         contains=xxdSep
syn match xxdSep contained ":"
syn match xxdAscii "  .\{,16\}\r\=$"hs=s+2  contains=xxdDot
syn match xxdDot contained "[.\r]"

syn match xxdHex "[0-9a-f]\{4}"       contains=xxdNull,xxdNewline
syn match xxdNull contained "\<00\|00\>"
syn match xxdNewline contained "\<0a\|0a\>\|\<0d\|0d\>"


" Define the default highlighting.
hi def link xxdAddress Label
hi def link xxdDot NonText
hi def link xxdSep NonText
hi def link xxdNull NonText
hi def link xxdNewline SpecialChar
hi def link xxdAscii String

let b:current_syntax = "xxd"
