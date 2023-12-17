#!/usr/bin/env bash

update(){
    eww -c $XDG_CONFIG_HOME/eww/shell update kbd_${1}=${2}
}
key(){
    [[ $2 == "on" ]]&&flag=":1"||flag=":0"
    ydotool key "${1}${flag}"
}
get_val(){
    eval "$(eww -c $XDG_CONFIG_HOME/eww/shell get "$1")"
}

case $1 in
    super)
        if get_val kbd_super; then
            key 125 off
            update super false
        else
            key 125 on
            update super true
        fi
        ;;
    shift)
        if get_val kbd_shift; then
            key 42 off
            update shift false
        else
            key 42 on
            update shift true
        fi
        ;;
    ctrl)
        if get_val kbd_ctrl; then
            key 29 off
            update ctrl false
        else
            key 29 on
            update ctrl true
        fi
        ;;
    alt)
        if get_val kbd_alt; then
            key 56 off
            update alt false
        else
            key 56 on
            update alt true
        fi
        ;;
        # &&flag="0"||flag="1"
        # ydotool key 125:${flag}
esac
