#!/bin/bash

eww -c $XDG_CONFIG_HOME/eww/shell close prompt_window; then
hyprctl dispatch submap reset

if [ -d "$1" ]
then
    nautilus "$1" -w & disown
else
    xdg-open "$1" & disown
fi
