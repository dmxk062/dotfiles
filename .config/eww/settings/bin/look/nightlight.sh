#!/usr/bin/env bash

eww="eww -c $HOME/.config/eww/settings"

if killall wlsunset
then
    $eww update look_nightlight=false
else
    $eww update look_nightlight=true
    wlsunset -T 4000 -t 3000& disown
fi

