#!/usr/bin/env bash

eww="eww -c $HOME/.config/eww/shell"

case $1 in
    next)
        hyprctl dispatch workspace m+1;;
    prev)
        hyprctl dispatch workspace m+1;;
esac

$eww update new_ws="$(hyprctl -j activeworkspace)"
if ! pgrep "ws_popup"
then
    $eww open workspace_popup --screen 0 
    sleep 2
    $eww close workspace_popup
fi
