#!/usr/bin/env bash

function octal_to_human(){
    octal="$1"
    for ((i=0; i<${#octal}; i++))
    do
        c=${octal:$i:1}
        if [[ $((c-4))]]
        then
    done

}

file="$1"
read -r octal human group_id group_name user_id user_name <<< "$(stat --format="%a %A %g %G %u %U" "$file")"
octal_to_human "$octal"
