#!/bin/sh

eww="eww -c $HOME/.config/eww/shell"

if $eww active-windows | grep "mpris_popup"; then
    sleep 0.2
    $eww close mpris_popup
else
    $eww open mpris_popup --anchor "top center"
fi


