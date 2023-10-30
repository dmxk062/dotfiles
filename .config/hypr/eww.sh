#!/bin/bash

EWWDIR="$XDG_CONFIG_HOME/eww"

for proc in eww  mpris.sh ws.sh notif.sh hyprmon.sh
do
    killall $proc
done

for eww_daemon in top-bar popups settings 
do
    eww -c $EWWDIR/$eww_daemon daemon & disown
done

for eww_window in bar dock_edge
do
    eww -c $EWWDIR/top-bar open $eww_window & disown
done

~/.config/eww/settings/bin/notif.sh monitor & disown
$EWWDIR/top-bar/bin/open_dock.sh & disown
sleep 2


$EWWDIR/settings/bin/audio_state.sh
$EWWDIR/settings/bin/sinks_sources.sh upd sinks & disown
$EWWDIR/settings/bin/sinks_sources.sh upd sources & disown
$EWWDIR/top-bar/bin/hyprmon.sh monitor & disown
# ~/.config/HOME/panel/bin/notif.sh monitor & disown
