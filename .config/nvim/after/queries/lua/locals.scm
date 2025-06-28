; extends
(variable_declaration 
  (assignment_statement
    (variable_list
      name: (identifier) @local.definition.function)
  (expression_list
    value: (function_definition))))

(assignment_statement
  (variable_list
    name: (dot_index_expression) @local.definition.function)
  (expression_list
    value: (function_definition)))
