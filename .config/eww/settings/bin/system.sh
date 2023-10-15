#!/bin/bash
eww="eww -c $HOME/.config/eww/settings"



idle(){
    if killall swayidle 
    then
        $eww update idle=false
    else
        swayidle -w & disown
        $eww update idle=true
    fi
}
clock(){
    if killall gnome-clocks
    then
        $eww update clocks=false
    else
        gnome-clocks --gapplication-service & disown
        $eww update clocks=true
    fi
}


case $1 in
    edge)
        edge;;
    idle)
        idle;;
    clock)
        clock;;
esac
