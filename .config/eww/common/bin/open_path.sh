#!/bin/sh

eww -c $XDG_CONFIG_HOME/eww/settings/ close settings
if [ -d "$1" ]
then
    nemo $1 --name="popup nemo"
else
    nemo "$(dirname $1)" --name="popup nemo"
fi
eww -c $XDG_CONFIG_HOME/eww/settings/ open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
