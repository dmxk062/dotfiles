#!/bin/bash

EWWDIR="$XDG_CONFIG_HOME/eww"

for proc in eww  mpris.sh ws.sh hyprmon.sh
do
    killall $proc
done

for eww_daemon in shell settings 
do
    eww -c $EWWDIR/$eww_daemon daemon & disown
done

for eww_window in bar dock_edge "desktop_area --screen 0"
do
    eww -c $EWWDIR/shell open $eww_window  & disown
done

# ~/.config/eww/settings/bin/notif.sh monitor & disown
$EWWDIR/shell/dock/bin/open_dock.sh & disown
sleep 2


mkdir -p '/tmp/eww/cache/clip' '/tmp/eww/cache/qr' '/tmp/eww/cache/wifi' '/tmp/eww/state/displays' '/tmp/eww/state/gaming' '/tmp/eww/state/prompt'

$EWWDIR/settings/bin/audio_state.sh
$EWWDIR/settings/bin/sinks_sources.sh upd sinks & disown
$EWWDIR/settings/bin/sinks_sources.sh upd sources & disown
$EWWDIR/shell/bin/hyprmon.sh monitor & disown
$EWWDIR/settings/bin/look/color.sh get
# ~/.config/HOME/panel/bin/notif.sh monitor & disown
