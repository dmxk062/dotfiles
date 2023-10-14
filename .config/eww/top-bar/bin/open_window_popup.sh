#!/bin/bash

eww="eww -c $HOME/.config/eww/top-bar"

case $1 in
    menu)
        if ! $eww close window_controls 
        then
            $eww open window_controls
        fi
        ;;
esac


