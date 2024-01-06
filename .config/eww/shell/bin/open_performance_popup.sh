#!/bin/sh

eww="eww -c $HOME/.config/eww/shell"

if $eww active-windows | grep "performance_popup"; then
    sleep 0.2
    $eww close performance_popup
else
    $eww open performance_popup
fi
