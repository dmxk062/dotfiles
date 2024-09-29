; extends
((cast_expression
 value: (identifier) @variable.typecast)
    (#set! priority 1000))
((cast_expression
 type: (type_descriptor) @type.typecast)
    (#set! priority 1000))
