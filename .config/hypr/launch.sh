#!/bin/bash
# swww init
# sleep 0.5
# $HOME/.config/background/setwallpaper
$HOME/.config/background/wallpaper.sh set
$HOME/.config/hypr/eww.sh & disown
killall udiskmon 
$HOME/.config/mako/scripts/udiskmon.sh & disown #script to mount inserted usbs
swayidle -w& disown #idle daemon for lockscreen & suspending
killall playerctld 
playerctld& disown #allows me to control mpris stuff with keybinds
