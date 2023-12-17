#!/usr/bin/env bash

# THIS IS HARDCODED FOR MY CURRENT LAPTOP

function rotate_ms {
    case $1 in
        "normal")
            rotate 0
            ;;
        "right-up")
            rotate 3
            ;;
        "bottom-up")
            rotate 2
            ;;
        "left-up")
            rotate 1
            ;;
    esac
}

function rotate {
    hyprctl keyword monitor eDP-1,transform,"$1"
    hyprctl keyword device:wacom-hid-52d3-finger:transform "$1"
    echo "$1"
    eww -c $HOME/.config/eww/shell reload
}
while IFS=$'\n' read -r line; do
    rotation="$(echo $line | sed -En "s/^.*orientation changed: (.*)/\1/p")"
    [[ -n  $rotation  ]] && rotate_ms $rotation
done < <(stdbuf -oL monitor-sensor)

