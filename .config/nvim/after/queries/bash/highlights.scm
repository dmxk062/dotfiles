; extends

; usually "--" as a command argument is more of a metasyntactic thing
(command
  argument: [ (word) @punctuation.delimiter ]
  (#eq? @punctuation.delimiter "--"))

; Highlight associative array declarations
; TODO: highlight simple forms, e.g.
; declare -A array=(
;   [val]=1
; )
(array
  (concatenation 
    (word) @punctuation.delimiter
    [ (string) (number) ((word) @property) ]
    (word) @punctuation.delimiter
    (word) @operator
  (#eq? @operator "=")
  (#any-of? @punctuation.delimiter "]" "[")))
