#!/bin/bash

eww="eww -c $HOME/.config/eww/shell"

[ -f /tmp/.eww_no_popups ]&&exit

get_screen(){
    hyprctl monitors -j|jq '.[]|select(.focused)|.id'
}

case $1 in 
    in)
        oldid=$(pgrep "open_popup" |head -n 1)
        if [[ $oldid == $BASHPID ]]
        then
            $eww open in_popup --screen $(get_screen)
            sleep 2
            $eww close in_popup
        fi
        ;;
    out)
        oldid=$(pgrep "open_popup" |head -n 1)
        if [[ $oldid == $BASHPID ]]
        then
            $eww open out_popup --screen $(get_screen)
            sleep 2
            $eww close out_popup
        fi
        ;;
    light)
        oldid=$(pgrep "open_popup" |head -n 1)
        if [[ $oldid == $BASHPID ]]
        then
            $eww open bright_popup --screen $(get_screen)
            sleep 2
            $eww close bright_popup
        fi
        $eww update brightness=$(light -G)
        ;;

        
esac
