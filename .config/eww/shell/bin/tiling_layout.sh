#!/usr/bin/env bash

case $1 in
    orientation)
        hyprctl dispatch layoutmsg orientationcycle left top
        ;;
    *)
        KEY="general:layout"
        case "$(hyprctl -j getoption "$KEY"|jq '.str' -r)" in
            dwindle)
                keywd=master
                ;;
            master|*)
                keywd=dwindle
                ;;
        esac
        hyprctl keyword "$KEY" "$keywd"
        eww -c "$XDG_CONFIG_HOME"/eww/shell update tiling_layout="$keywd"
    ;;
esac
