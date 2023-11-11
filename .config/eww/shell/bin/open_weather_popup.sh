#!/bin/sh

eww="eww -c $HOME/.config/eww/shell"

if ! $eww close weather_popup 
then
    $eww open weather_popup
fi


