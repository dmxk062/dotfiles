#!/bin/bash
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

function nightlight(){
if killall wlsunset
then
    $eww update nightlight=false
else
    $eww update nightlight=true
    wlsunset -T 4000 -t 3000
fi
}


function blur(){
if [[ $(hyprctl_keywd "decoration:blur:enabled" int) == "0" ]]
then
    hyprctl keyword decoration:blur:enabled true
    $eww update blur=true
else
    hyprctl keyword decoration:blur:enabled false
    $eww update blur=false
fi
}
function blur_xray(){
if [[ $(hyprctl_keywd "decoration:blur:xray" int) == "0" ]]
then
    hyprctl keyword decoration:blur:xray true
    $eww update blur_xray=true
else
    hyprctl keyword decoration:blur:xray false
    $eww update blur_xray=false
fi
}
function rounding(){
    if [[ $(hyprctl_keywd "decoration:rounding" int) != "12" ]]
    then
        hyprctl keyword decoration:rounding 12
        $eww update rounding=true
    else
        hyprctl keyword decoration:rounding 0
        $eww update rounding=false
    fi

}
border() {
    if [[ $(hyprctl_keywd "general:border_size" int) != "2" ]]
    then
        hyprctl keyword general:border_size 2
        $eww update border=true
    else
        hyprctl keyword general:border_size 0
        $eww update border=false
    fi
}   

opacity() {
    if [[ $(< "$HOME/.config/kitty/opacity.conf") != "background_opacity 0.9" ]]
    then
        for kitty in /tmp/kitty-*
        do
        kitten @ --to unix:$kitty set-background-opacity 0.9
        done
        echo "background_opacity 0.9" > "$HOME/.config/kitty/opacity.conf"
        $eww update opacity=true
    else
        for kitty in /tmp/kitty-*
        do
        kitten @ --to unix:$kitty set-background-opacity 1
        done
        echo "background_opacity 1" > "$HOME/.config/kitty/opacity.conf"
        $eww update opacity=false
    fi

}

shadow() {
    if [[ $(hyprctl_keywd "decoration:drop_shadow" int) == "0" ]]
    then
        hyprctl keyword decoration:drop_shadow 1
        $eww update shadow=true
    else
        hyprctl keyword decoration:drop_shadow 0
        $eww update shadow=false
    fi
}   
special_blur() {
    if [[ $(hyprctl_keywd "decoration:blur:special" int) == "0" ]]
    then
        hyprctl keyword decoration:blur:special 1
        $eww update special_blur=true
    else
        hyprctl keyword decoration:blur:special 0
        $eww update special_blur=false
    fi
}   
gaps_in() {
    if [[ $(hyprctl_keywd "general:gaps_in" int) != "4" ]]
    then
        hyprctl keyword general:gaps_in 4
        $eww update gaps_in=true
    else
        hyprctl keyword general:gaps_in 0
        $eww update gaps_in=false
    fi
}   
gaps_out() {
    if [[ $(hyprctl_keywd "general:gaps_out" int) != "8" ]]
    then
        hyprctl keyword general:gaps_out 8
        $eww update gaps_out=true
    else
        hyprctl keyword general:gaps_out 0
        $eww update gaps_out=false
    fi
}   

case $1 in 
    nightlight)
        nightlight;;
    blur)
        blur;;
    blur_xray)
        blur_xray;;
    rounding)
        rounding;;
    border)
        border;;
    opacity)
        opacity;;
    shadow)
        shadow;;
    special_blur)
        special_blur;;
    gaps_in)
        gaps_in;;
    gaps_out)
        gaps_out;;
esac
