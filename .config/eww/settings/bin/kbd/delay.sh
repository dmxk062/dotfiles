#!/bin/sh

eww="eww -c $HOME/.config/eww/settings"
set_delay(){
    val=$1
    hyprctl keyword input:repeat_delay $val
    $eww update input_repeat_delay=$val
}

case $1 in
    reset)
        set_delay 600;;
    *)
        set_delay $1;;
esac
