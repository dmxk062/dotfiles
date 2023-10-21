#!/usr/bin/env bash

eww="eww -c $HOME/.config/eww/settings"

$eww close settings
connection=$(nmcli -g UUID,NAME con|awk -v ssid="$1" -F: '$2==ssid{print $1}')
nm-connection-editor --edit=$connection
$eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')

