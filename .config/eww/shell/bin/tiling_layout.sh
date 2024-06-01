#!/usr/bin/env bash

KEY="general:layout"
ICON="/usr/share/icons/Tela/scalable/apps/preferences-desktop-theme-windowdecorations.svg"
case "$(hyprctl -j getoption "$KEY"|jq '.str' -r)" in
    dwindle)
        keywd=master
        ;;
    *)
        keywd=dwindle
        ;;
esac
echo "$keywd"
hyprctl keyword "$KEY" "$keywd"
eww -c "$XDG_CONFIG_HOME"/eww/shell update tiling_layout="$keywd"
