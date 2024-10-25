#!/bin/false
# vim: ft=zsh

# tools for working with a gui session

if [[ "$1" == "unload" ]]; then

    unfunction wintype winsend

    return
fi

# write text on stdin to window given on "$1" as hyprland pattern
function wintype {
    local pattern="$1"
    local curwin="$(hyprctl -j activewindow|jq -r '.address')"
    if [[ -t 0 ]]; then
        local line
        while read -r line; do
            hyprctl dispatch "focuswindow $1" > /dev/null
            ydotool type -d 1 -- "$line"
            hyprctl dispatch "focuswindow address:$curwin" > /dev/null
        done
    else
        hyprctl dispatch "focuswindow $1" > /dev/null
        ydotool type -d 1 -f -
        hyprctl dispatch "focuswindow address:$curwin" > /dev/null
    fi
}

# send text via clipboard, as if typing <C-v>
function winsend {
    local pattern="$1"
    local curwin="$(hyprctl -j activewindow|jq -r '.address')"
    local old_sel="$(mktemp)"

    # save old clipboard
    wl-paste > "$old_sel"

    wl-copy -o
    hyprctl dispatch "focuswindow $pattern" > /dev/null
    # CTRL down V down V up CTRL up
    ydotool key 29:1 47:1 47:0 29:0
    hyprctl dispatch "focuswindow address:$curwin" > /dev/null

    # restore clipboard
    nohup wl-copy -n < "$old_sel" > /dev/null 2>/dev/null
    rm -f "$old_sel"
}
