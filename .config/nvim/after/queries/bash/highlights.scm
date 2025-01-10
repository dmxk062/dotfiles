; extends

; usually "--" as a command argument is more of a metasyntactic thing
(command 
  argument: [
             (word) @punctuation.delimiter

             ]
  (#eq? @punctuation.delimiter "--"))
