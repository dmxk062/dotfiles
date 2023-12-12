#!/bin/bash

declare -A colors=(
    ["0"]="2e3440" #black
    ["1"]="bf616a" #red
    ["2"]="a3be8c" #green
    ["3"]="ebcb8b" #yellow
    ["4"]="5e81ac" #blue
    ["5"]="b48ead" #magenta
    ["6"]="8fbcbb" #cyan
    ["7"]="eceff4" #white
    ["8"]="2e3440"
    ["9"]="bf616a"
    ["A"]="a3be8c"
    ["B"]="ebcb8b"
    ["C"]="5e81ac"
    ["D"]="b48ead"
    ["E"]="8fbcbb"
    ["F"]="eceff4"
)
for code in "${!colors[@]}"; do
    echo "\e]P${code}${colors[$code]}"
done
