#!/usr/bin/env bash

eww="eww -c $HOME/.config/eww/settings"

if killall gammastep
then
    $eww update look_nightlight=false
else
    $eww update look_nightlight=true
    gammastep -O 3000 & disown
fi

