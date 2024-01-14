#!/bin/bash
# swww init
# sleep 0.5
# $HOME/.config/background/setwallpaper
$HOME/.config/background/wallpaper.sh set
$HOME/.config/hypr/eww.sh & disown
killall udiskmon 
$XDG_CONFIG_HOME/eww/shell/dock/bin/nwg_drawer.sh --initial& disown 
$HOME/.config/mako/scripts/diskmon.sh & disown #script to notify about inserted usbs
swayidle -w& disown #idle daemon for lockscreen & suspending
killall playerctld 
playerctld& disown #allows me to control mpris stuff with keybinds
