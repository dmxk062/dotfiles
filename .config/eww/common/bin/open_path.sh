#!/bin/sh

eww -c $XDG_CONFIG_HOME/eww/settings/ close settings
gsettings set org.gnome.nautilus.window-state initial-size "(800, 600)"
if [ -d "$1" ]
then
    nautilus "$1" -w
else
    nautilus "$(dirname $1)" -w
fi
