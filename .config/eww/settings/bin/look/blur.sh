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


function blur_win(){
if [[ $(hyprctl_keywd "decoration:blur:enabled" int) == "0" ]]
then
    hyprctl keyword decoration:blur:enabled true
    $eww update look_blur_win=true
else
    hyprctl keyword decoration:blur:enabled false
    $eww update look_blur_win=false
fi
}
function blur_xray(){
if [[ $(hyprctl_keywd "decoration:blur:xray" int) == "0" ]]
then
    hyprctl keyword decoration:blur:xray true
    $eww update look_blur_xray=true
else
    hyprctl keyword decoration:blur:xray false
    $eww update look_blur_xray=false
fi
}
blur_special() {
    if [[ $(hyprctl_keywd "decoration:blur:special" int) == "0" ]]
    then
        hyprctl keyword decoration:blur:special 1
        $eww update look_blur_special=true
    else
        hyprctl keyword decoration:blur:special 0
        $eww update look_blur_special=false
    fi
}   


case $1 in
    win)
        blur_win;;
    ws)
        blur_special;;
    xray)
        blur_xray;;
esac
