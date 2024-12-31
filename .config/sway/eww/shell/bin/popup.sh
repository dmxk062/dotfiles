#!/bin/sh

# $1 : window to open/close
# $2 : variable to check if open
# $3 : action: open|close

EWW="$XDG_CONFIG_HOME/sway/eww/shell"

value="$(eww -c "$EWW" get "$2")"
if [ "$value" = true ] || [ "$3" = close ]; then
    eww -c "$EWW" update "$2"=false
    sleep 0.5
    new_value="$(eww -c "$EWW" get "$2")"
    if [ "$new_value" = "false" ] && eww -c "$EWW" list-windows | grep -q "$1"; then
        eww -c "$EWW" close "$1"
    fi
else
    eww -c "$EWW" update "$2"=true
    eww -c "$EWW" open "$1"
fi
