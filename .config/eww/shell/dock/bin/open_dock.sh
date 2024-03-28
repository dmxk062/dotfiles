#!/bin/bash


eww="eww -c $HOME/.config/eww/shell"

# $eww update dock_reveal=false
# sleep 0.2
# if ! $eww close dock_window 
# then
#     $eww open dock_window
#     $eww update dock_reveal=true
#     $eww update apps="$(< $XDG_CONFIG_HOME/eww/shell/dock/apps.json)"
# fi

if [[ $($eww get dock_reveal) == "true" ]]; then
    $eww update dock_reveal=false
    sleep 0.2
    $eww close dock_window
else
    $eww open dock_window
    $eww update dock_reveal=true
    $eww update apps="$(< $XDG_CONFIG_HOME/eww/shell/dock/apps.json)"
fi

