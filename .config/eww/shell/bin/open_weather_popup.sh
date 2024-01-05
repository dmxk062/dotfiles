#!/bin/bash

eww="eww -c $HOME/.config/eww/shell"

if $eww active-windows | grep "weather_popup"; then
    sleep 0.1
    $eww close weather_popup
else
    $eww open weather_popup
    if [[ $1 -gt 300 ]]; then
        $XDG_CONFIG_HOME/eww/shell/bin/weather.sh upd "$2"
    fi
fi


