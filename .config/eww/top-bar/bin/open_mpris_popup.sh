#!/bin/sh

eww="eww -c $HOME/.config/eww/top-bar"

if ! $eww close mpris_popup 
then
    $eww open mpris_popup
fi


