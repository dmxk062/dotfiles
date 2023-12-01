#!/usr/bin/env bash
eww="eww -c $HOME/.config/eww/settings"


idle(){
    if killall swayidle 
    then
        $eww update service_idle=false
    else
        swayidle -w & disown
        $eww update service_idle=true
    fi
}
clock(){
    if killall gnome-clocks
    then
        $eww update service_clocks=false
    else
        gnome-clocks --gapplication-service & disown
        $eww update service_clocks=true
    fi
}

blueman(){
    if killall blueman-applet
    then
        $eww update service_blueman=false
    else
        blueman-applet & disown
        $eww update service_blueman=true
    fi
}

networkmanager(){
    if killall nm-applet
    then
        $eww update service_nm=false
    else
        nm-applet & disown
        $eww update service_nm=true
    fi
}



case $1 in
    idle)
        idle;;
    clock)
        clock;;
    blueman)
        blueman;;
    network)
        networkmanager;;
esac

