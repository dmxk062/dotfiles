#!/bin/bash
eww="eww -c $HOME/.config/eww/settings"
function toggle(){
    if killall $1
    then
        $eww update "$2"=false
    else
        $1 $3& disown
        $eww update "$2"=true
    fi

}


case $1 in
    blueman)
        toggle blueman-applet blueman_tray;;
    nm)
        toggle nm-applet nm_tray;;
    obs)
        toggle obs obs_tray "--minimize-to-tray"
esac
