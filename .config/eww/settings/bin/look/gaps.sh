#!/usr/bin/env bash
eww="eww -c $HOME/.config/eww/settings"

function hyprctl_keywd(){
    value="$(hyprctl -j getoption $1)"
    if [[ $2 == "int" ]]
    then
        echo "$value"|jq '.int' -r
    else
        echo "$value"|jq '.str' -r
    fi
}

gaps_in() {
    if [[ $(hyprctl_keywd "general:gaps_in" int) != "4" ]]
    then
        hyprctl keyword general:gaps_in 4
        $eww update look_gaps_in=true
    else
        hyprctl keyword general:gaps_in 0
        $eww update look_gaps_in=false
    fi
}   
gaps_out() {
    if [[ $(hyprctl_keywd "general:gaps_out" int) != "8" ]]
    then
        hyprctl keyword general:gaps_out 8
        $eww update look_gaps_out=true
    else
        hyprctl keyword general:gaps_out 0
        $eww update look_gaps_out=false
    fi
}   

gaps_$1
