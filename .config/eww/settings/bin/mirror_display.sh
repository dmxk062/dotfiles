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
    update monitor_mirrored '{"source":"","target":""}'
}


mkdir -p "$FSPATH"

on(){
    background "$source" "$target" & 
    sleep 0.1
    hyprctl dispatch moveworkspacetomonitor name:mirror $target
    sleep 0.1
    hyprctl dispatch focusmonitor mon:${source}
    state="$(printf '{"source":"%s","target":"%s"}' "$source" "$target")"
    update monitor_mirrored "$state"
}
off(){
    read -r source target pid < "${FSPATH}/mirrored"
    kill $pid
}

source="$2"
target="$3"
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
esac


