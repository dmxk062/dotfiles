#!/usr/bin/env bash

PROMPT="\0prompt\x1f"
ICON="\0icon\x1f"
SET_DELIM="\0delim\x1f"

print_walls() {
    echo -en "${PROMPT}Wallpapers...\t"
    for file in "$XDG_CONFIG_HOME"/background/img/*; do
        name="${file##*/}"
        printf "%s$ICON%s\t" "$name" "$file"
    done
}

if ((ROFI_RETV != 0)); then
    ~/.config/background/wallpaper.sh both "$XDG_CONFIG_HOME/background/img/$1" >/dev/null 2>&1
else
    echo -en "$SET_DELIM\t\n"
fi

print_walls
