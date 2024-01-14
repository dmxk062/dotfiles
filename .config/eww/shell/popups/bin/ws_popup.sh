#!/usr/bin/env bash

eww="eww -c $HOME/.config/eww/shell"

LOCKFILE="/tmp/eww/state/ws_popup_active"
case $1 in
    next)
        hyprctl dispatch workspace m-1;;
    prev)
        hyprctl dispatch workspace m+1;;
esac

[ -f "/tmp/eww/state/no_popups" ]&&exit
if ! [ -f "$LOCKFILE" ]
then
    touch "$LOCKFILE"
    $eww open workspace_popup --screen 0 
    sleep 2
    $eww close workspace_popup
    rm "$LOCKFILE"
fi
