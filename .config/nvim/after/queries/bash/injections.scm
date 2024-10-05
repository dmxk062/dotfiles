; extends

(command
   name: (command_name) @_command
   argument : [
               (string 
                 (string_content) @injection.content)
               (concatenation 
                 (string
                   (string_content) @injection.content))
               (raw_string) @injection.content
               (concatenation 
                 (raw_string) @injection.content)
               ]
 (#eq? @_command "jq")
 (#set! injection.language "jq"))

(command
   name: (command_name) @_command
   argument : [
               (string 
                 (string_content) @injection.content)
               (concatenation 
                 (string
                   (string_content) @injection.content))
               (raw_string) @injection.content
               (concatenation 
                 (raw_string) @injection.content)
               ]
 (#eq? @_command "awk")
 (#set! injection.language "awk"))
