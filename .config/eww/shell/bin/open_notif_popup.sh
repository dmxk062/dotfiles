#!/bin/sh

eww="eww -c $HOME/.config/eww/shell"

if $eww active-windows | grep "notifcenter"; then
    sleep 0.1
    $eww close notifcenter
else
    $eww open notifcenter
fi


