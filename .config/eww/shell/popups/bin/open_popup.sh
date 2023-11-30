#!/bin/bash

eww="eww -c $HOME/.config/eww/shell"

[ -f /tmp/.eww_no_popups ]&&exit

case $1 in 
    in)
        oldid=$(pgrep "open_popup" |head -n 1)
        if [[ $oldid == $BASHPID ]]
        then
            $eww open in_popup --screen 0
            sleep 2
            $eww close in_popup
        fi
        ;;
    out)
        oldid=$(pgrep "open_popup" |head -n 1)
        if [[ $oldid == $BASHPID ]]
        then
            $eww open out_popup --screen 0
            sleep 2
            $eww close out_popup
        fi
        ;;
    light)
        oldid=$(pgrep "open_popup" |head -n 1)
        if [[ $oldid == $BASHPID ]]
        then
            $eww open bright_popup --screen 0
            sleep 2
            $eww close bright_popup
        fi
        $eww update brightness=$(light -G)
        ;;

        
esac
