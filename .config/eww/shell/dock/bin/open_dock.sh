#!/bin/bash

eww="eww -c $HOME/.config/eww/shell"

if ! $eww close dock_window 
then
    $eww update apps="$(< $XDG_CONFIG_HOME/eww/shell/dock/apps.json)"
    $eww open dock_window
    $eww update dock_reveal=true
else
    $eww update dock_reveal=false
fi


