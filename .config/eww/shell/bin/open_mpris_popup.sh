#!/bin/sh

eww="eww -c $HOME/.config/eww/shell"

if ! $eww close mpris_popup 
then
    $eww open mpris_popup --screen 0 --anchor "top center"
fi


