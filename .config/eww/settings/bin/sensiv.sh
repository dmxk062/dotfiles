#!/bin/zsh

eww="eww -c $HOME/.config/eww/settings"
function set(){
    val=$1
    if ((val >= 0 && val <= 100 ))
        then
            newval="$(((val * 2.0 - 100.0)/100.0))"
            hyprctl keyword input:sensitivity $newval
            eval "$eww update mouse_sensitivity=$val"
    fi
}

case $1 in
    reset)
        set 50;;
    *)
        set $1;;
esac
