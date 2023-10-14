#!/bin/bash


eww_settings="eww -c $HOME/.config/eww/settings"

function list(){
    hyprctl -j monitors|jq 'sort_by(.x)' -c
}
case $1 in
    upd)
        $eww_settings update monitors="$(list)";;
esac
