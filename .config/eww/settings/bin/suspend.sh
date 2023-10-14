#!/bin/bash

eww="eww -c $HOME/.config/eww/settings"

$eww close settings
$@
$eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
