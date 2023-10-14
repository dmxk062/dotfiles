#!/bin/zsh

eww="eww -c $HOME/.config/eww/settings"
function set(){
    val=$1
    hyprctl keyword input:repeat_delay $val
    eval "$eww update repeat_delay=$val"
}

case $1 in
    reset)
        set 600;;
    *)
        set $1;;
esac
