#!/usr/bin/env bash
eww="eww -c $HOME/.config/eww/shell"

case $1 in 
    on)
        [ -f /tmp/.eww_no_popups ]&&exit
        $eww open submap_popup --screen 0
        ;;
    off)
        $eww close submap_popup
        ;;
esac
