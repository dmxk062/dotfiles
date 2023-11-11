#!/bin/sh

eww="eww -c $HOME/.config/eww/shell"

if ! $eww close notifcenter 
then
    $eww open notifcenter
fi


