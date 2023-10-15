#!/bin/bash
eww="eww -c $HOME/.config/eww/settings"



edge(){
    if eww -c "$XDG_CONFIG_HOME/eww/top-bar/" close dock_edge
    then
        $eww update edge=false
        eww -c "$XDG_CONFIG_HOME/eww/top-bar/" close dock_window
    else
        eww -c "$XDG_CONFIG_HOME/eww/top-bar" open dock_edge
        eww -c "$XDG_CONFIG_HOME/eww/top-bar" open dock_window
        $eww update edge=true
    fi
}
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
