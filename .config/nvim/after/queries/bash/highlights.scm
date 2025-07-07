; extends

; usually "--" as a command argument is more of a metasyntactic thing
(command
  argument: [ (word) @punctuation.delimiter ]
  (#eq? @punctuation.delimiter "--"))

; Highlight associative array declarations
(array
  (concatenation
    (word) @punctuation.delimiter
    [ (string) (number) ((word) @property) ]
    (word) @punctuation.delimiter
    (word) @operator
    (#lua-match? @operator "^=")
    (#jhk-set-length! @operator 1)
    (#any-of? @punctuation.delimiter "]" "[")))

; make bash "keywords" behave like other languages
((command
   name: (command_name (word)) @keyword.return
   (#any-of? @keyword.return "return" "exit" "break")))
