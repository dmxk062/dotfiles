#!/usr/bin/env bash

eww="eww -c $HOME/.config/eww/shell"

LOCKFILE="/tmp/.eww_ws_popup_shown"

case $1 in
    next)
        hyprctl dispatch workspace m-1;;
    prev)
        hyprctl dispatch workspace m+1;;
esac

[ -f /tmp/.eww_no_popups ]&&exit
$eww update new_ws="$(hyprctl -j activeworkspace)"
if ! [ -f "$LOCKFILE" ]
then
    touch "$LOCKFILE"
    $eww open workspace_popup --screen 0 
    sleep 2
    $eww close workspace_popup
    rm "$LOCKFILE"
fi
