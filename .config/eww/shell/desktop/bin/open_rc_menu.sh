#!/bin/bash

eww="eww -c $XDG_CONFIG_HOME/eww/shell"
get_relative_cursor(){
    read -r x y <<< $(hyprctl cursorpos |sed 's/,//')
    monitors="$(hyprctl -j monitors)"
    read -r x_r y_r <<< "$(echo "$monitors"|jq '.[]|select(.focused)|.x, .y' --raw-output0|tr '\0' ' ')"
    case $(echo "$monitors"|jq -r '.[]|select(.focused)|.name') in
        DP-1|eDP-1)
            scalex=50
            scaley=70
            ;;
        *)
            scalex=70
            scaley=25
            ;;
    esac
    echo "$(((x-x_r)-scalex))x$(((y-y_r)-scaley))" 
}
$eww open --screen 0 --toggle rc_popup --pos=$(get_relative_cursor)
$eww update rc_win_area=0 rc_desktop_area=0
 
case $1 in
    desktop)
        $eww update rc_start_desktop=true;;
    window)
        $eww update rc_start_desktop=false;;
    move) 
        $eww update rc_win_area=1;;
esac
