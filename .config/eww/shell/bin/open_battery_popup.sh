#!/bin/sh

eww="eww -c $HOME/.config/eww/shell"

if ! $eww close battery_popup 
then
    $eww open battery_popup
fi


