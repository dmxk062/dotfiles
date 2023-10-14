#!/bin/zsh

eww="eww -c $HOME/.config/eww/settings"
function set(){
    newval=$((${1}/100.0))
    echo $val
    hyprctl keyword input:touchpad:scroll_factor $newval
    eval "$eww update scroll_speed=$1"
}

case $1 in
    reset)
        set 101;;
    *)
        set $1;;
esac
