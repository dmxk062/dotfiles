#!/bin/bash
killall eww
killall wifi.sh
killall mpris.sh
killall ws.sh
killall notif.sh
killall hyprmon.sh
eww -c $XDG_CONFIG_HOME/eww/top-bar daemon & disown
eww -c $XDG_CONFIG_HOME/eww/top-bar open bar & disown
eww -c $XDG_CONFIG_HOME/eww/top-bar open dock_edge & disown
eww -c $XDG_CONFIG_HOME/eww/popups daemon & disown
eww -c $XDG_CONFIG_HOME/eww/settings daemon & disown
~/.config/eww/settings/bin/notif.sh monitor & disown
sleep 2
$XDG_CONFIG_HOME/eww/settings/bin/audio_state.sh
$XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sinks & disown
$XDG_CONFIG_HOME/eww/settings/bin/sinks_sources.sh upd sources & disown
$XDG_CONFIG_HOME/eww/top-bar/bin/hyprmon.sh monitor & disown
# ~/.config/HOME/panel/bin/notif.sh monitor & disown
