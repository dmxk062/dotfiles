#!/bin/bash

eww="eww -c $HOME/.config/eww/shell"

if ! $eww close dock_window 
then
    $eww update dock_reveal=true
    $eww open dock_window
    $eww update apps="$(< $XDG_CONFIG_HOME/eww/shell/dock/apps.json)"
else
    $eww update dock_reveal=false
fi


