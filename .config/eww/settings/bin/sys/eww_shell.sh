#!/usr/bin/env bash

eww="eww -c $HOME/.config/eww/settings"
eww_bar="eww -c $XDG_CONFIG_HOME/eww/shell/"

dock(){
    if  $eww_bar close dock_edge
    then
        $eww update dock=false
        $eww_bar close dock_window
    else
        $eww_bar open dock_edge
        $eww_bar open dock_window
        $eww update dock=true
    fi
}

rightclick(){
    if  $eww_bar close desktop_area
    then
        $eww update rightclick=false
        $eww_bar close desktop_area
    else
        $eww_bar open desktop_area --screen 0
        $eww update rightclick=true
    fi
}


bar(){
    if  $eww_bar close bar
    then
        $eww update bar=false
    else
        $eww_bar open bar
        $eww update bar=true
        $XDG_CONFIG_HOME/eww/settings/bin/audio_state.sh
        $XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sinks & disown
        $XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sources & disown
    fi
}

popups(){
    lockfile="/tmp/.eww_no_popups"
    if [ -f $lockfile ]
    then
        rm $lockfile
        $eww update popups=true
    else
        touch $lockfile
        $eww update popups=false
    fi
}

case $1 in 
dock)
    dock;;
bar)
    bar;;
popups)
    popups;;
desktop)
    rightclick;;
titlebar)
    if $XDG_CONFIG_HOME/hypr/plugins/plugins.sh toggle hyprbars
    then
        $eww update titlebars=true
    else
        $eww update titlebars=false
    fi
esac

