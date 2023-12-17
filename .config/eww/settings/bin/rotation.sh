#!/usr/bin/env bash

eww="eww -c $XDG_CONFIG_HOME/eww/shell"
# THIS IS HARDCODED FOR MY CURRENT LAPTOP

function rotate_ms {
    case $1 in
        "normal")
            rotate 0
            $eww update vertical=false
            ;;
        "right-up")
            rotate 3
            $eww update vertical=true
            ;;
        "bottom-up")
            rotate 2
            $eww update vertical=false
            ;;
        "left-up")
            rotate 1
            $eww update vertical=true
            ;;
    esac
    sleep 0.5
        eww -c $XDG_CONFIG_HOME/eww/shell update kbd_layout="$(< $XDG_CONFIG_HOME/eww/shell/kbd/layout.json)"
    $XDG_CONFIG_HOME/background/wallpaper.sh set

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

