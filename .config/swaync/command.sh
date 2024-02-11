#!/usr/bin/env bash

declare -A COMMANDS=(
["?"]="Show Help"
["q"]="Exit"
)

show_table(){
    title="$1"
    col1="$2"
    col2="$3"
    shift 3
    zenity --title="$title" --text="" --list --column="$col1" --column="$col2" $@
}
get_input(){
    zenity --entry \
        --text="$2" --title="$1"
}

comm="$(get_input "Command Entry" "Enter command to run:")"

case $comm in
    '?')
        show_table "Available Commands" "Command" "Action" "$(for command in "${!COMMANDS[@]}"; do
        echo "$command" "${COMMANDS[$command]}"
    done)"
        ;;
    'q')
        exit
        ;;
    *)
        
esac

