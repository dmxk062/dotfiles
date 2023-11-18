#!/bin/bash

eww="eww -c $XDG_CONFIG_HOME/eww/shell"
get_relative_cursor(){
    read -r x y <<< $(hyprctl cursorpos |sed 's/,//')
    read -r x_r y_r <<< "$(hyprctl monitors -j|jq '.[]|select(.focused)|.x, .y' --raw-output0|tr '\0' ' ')"
    echo "$((x-x_r-90))x$((y-y_r-100))" # those values are based on window size, i found these to be decent
}
$eww open --screen 0 --toggle rc_popup --pos=$(get_relative_cursor)
case $1 in
    desktop)
        $eww update rc_start_desktop=true;;
    window)
        $eww update rc_start_desktop=false;;
esac
