#!/bin/zsh

eww="eww -c $HOME/.config/eww/settings"
function set(){
    val=$1
    hyprctl keyword input:repeat_rate $val
    eval "$eww update repeat_rate=$val"
}

case $1 in
    reset)
        set 25;;
    *)
        set $1;;
esac
