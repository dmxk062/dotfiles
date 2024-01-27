#!/usr/bin/env bash

FSPATH="/tmp/eww/state/displays"

update(){
    eww -c "$XDG_CONFIG_HOME/eww/settings" update "$1"="$2"
}

background(){
    wl-mirror -F "$1" & 
    pid="$!"
    echo "${1} ${2} $pid" > "${FSPATH}/mirrored"
    wait $pid
    rm "${FSPATH}/mirrored"
    update monitor_mirrored '{"source":"","target":"","active":false}'
}


on(){
    background "$source" "$target" & 
    oldwin="$(hyprctl -j activewindow|jq '.address' -r)"
    sleep 0.1
    hyprctl dispatch moveworkspacetomonitor name:mirror $target
    sleep 1
    hyprctl dispatch focuswindow address:$oldwin
    state="$(printf '{"source":"%s","target":"%s","active":true}' "$source" "$target")"
    update monitor_mirrored "$state"
}
off(){
    read -r source target pid < "${FSPATH}/mirrored"
    kill $pid
}

source="$3"
target="$2"
case $1 in
    on)
        on
        ;;
    off)
        off
        ;;
    toggle)
        if [[ -f "${FSPATH}/mirrored" ]]; then
            off
        else
            on
        fi
        ;;
    interactive)
        if [[ -f "${FSPATH}/mirrored" ]]; then
            off
            exit
        fi
        eww -c $XDG_CONFIG_HOME/eww/settings close settings
        monitors="$(hyprctl -j monitors|jq '.[].name' -r)"
        args=""
        while IFS= read -r monitor; do
            if [[ "$monitor" != "$target" ]]; then
                args="${args} --extra-button=${monitor}"
            fi
        done <<< "${monitors}"

        source="$(zenity --question --icon=preferences-desktop-display-randr \
        --switch --text="Select the monitor to mirror" --title="Monitor Selection" $args)"
        if [[ "$target" == "" ]]; then
            eww_settings.sh display
            exit
        fi
        on
        eww_settings.sh display

esac


