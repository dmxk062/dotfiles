#!/usr/bin/env bash

screen=$(hyprctl -j monitors|jq '.[]|select(.focused).id')
eww -c $XDG_CONFIG_HOME/eww/settings open settings --screen $screen
set_section(){
    eww -c $XDG_CONFIG_HOME/eww/settings update selected_section=$1
}
case $1 in
    appearance)
        set_section 0
        ;;
    input)
        set_section 1
        ;;
    display)
        set_section 2
        $XDG_CONFIG_HOME/eww/settings/bin/display.sh upd
        ;;
    system)
        set_section 3
        $XDG_CONFIG_HOME/eww/settings/bin/system_info.sh
        ;;
    audio)
        set_section 4
        $XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sinks
        $XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sources
        ;;
    bluetooth)
        set_section 5
        $XDG_CONFIG_HOME/eww/settings/bin/bt.sh upd
        ;;
    wifi)
        set_section 6
        $XDG_CONFIG_HOME/eww/settings/bin/wlan.sh upd
        ;;
    storage)
        set_section 7
        $XDG_CONFIG_HOME/eww/settings/bin/disks.sh upd
        ;;
esac
