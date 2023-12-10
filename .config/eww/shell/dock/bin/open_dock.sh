#!/bin/bash


eww="eww -c $HOME/.config/eww/shell"

$eww update dock_reveal=false
if ! $eww close dock_window 
then
    $eww open dock_window
    $eww update dock_reveal=true
    $eww update apps="$(< $XDG_CONFIG_HOME/eww/shell/dock/apps.json)"
fi


