#!/bin/bash

eww="eww -c $XDG_CONFIG_HOME/eww/top-bar"
get_relative_cursor(){
    read -r x y <<< $(hyprctl cursorpos |sed 's/,//')
    read -r x_r y_r <<< "$(hyprctl monitors -j|jq '.[]|select(.focused)|.x, .y' --raw-output0|tr '\0' ' ')"
    echo "$((x-x_r-90))x$((y-y_r-250))" # those values are based on window size, i found these to be decent
}
json_path="$XDG_CONFIG_HOME/eww/top-bar/bin/icon_menus.json"
if [ -z $1 ]
then
    entry=default
    json=$(jq -Mc ".$entry" < "$json_path")
    $eww update icon_menu_entries="$json"
    $eww close icon_popup
    exit
else
    entry="$1"
fi
json=$(jq -Mc ".$entry" < "$json_path")
$eww update icon_menu_entries="$json"

$eww open --screen 0 --toggle --anchor "top left" icon_popup --pos=$(get_relative_cursor)
echo $(get_relative_cursor)
