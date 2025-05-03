syn case ignore
syn keyword confBool yes no on off true false
syn match confNumber "\<\d\.\?\d*\>"
syn match confOperator "[=$]"

hi def link confBool Boolean
hi def link confNumber Number
hi def link confOperator Operator
