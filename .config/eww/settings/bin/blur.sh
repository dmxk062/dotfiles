#!/bin/zsh
#
eww="eww -c $HOME/.config/eww/settings"
function set(){
    val=$(($1/100.0))
    keywd=$2
    hyprctl keyword decoration:blur:$keywd $val
    
    eval "$eww update blur_${keywd}=$1"
}
set $1 $2
