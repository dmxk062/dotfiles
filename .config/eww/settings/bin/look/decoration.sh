#!/usr/bin/env bash
eww="eww -c $HOME/.config/eww/settings"
KITTY_OPACITY=0.9

function hyprctl_keywd(){
    value="$(hyprctl -j getoption $1)"
    if [[ $2 == "int" ]]
    then
        echo "$value"|jq '.int' -r
    else
        echo "$value"|jq '.str' -r
    fi
}

opacity() {
    if [[ $(< "$HOME/.config/kitty/opacity.conf") != "background_opacity $KITTY_OPACITY" ]]
    then
        for kitty in /tmp/kitty-*
        do
        kitten @ --to unix:$kitty set-background-opacity $KITTY_OPACITY
        done
        echo "background_opacity $KITTY_OPACITY" > "$HOME/.config/kitty/opacity.conf"
        $eww update look_opacity=true
    else
        for kitty in /tmp/kitty-*
        do
        kitten @ --to unix:$kitty set-background-opacity 1
        done
        echo "background_opacity 1" > "$HOME/.config/kitty/opacity.conf"
        $eww update look_opacity=false
    fi
}

function rounding(){
    if [[ $(hyprctl_keywd "decoration:rounding" int) != "12" ]]
    then
        hyprctl keyword decoration:rounding 12
        $eww update look_rounding=true
    else
        hyprctl keyword decoration:rounding 0
        $eww update look_rounding=false
    fi
}

border() {
    if [[ $(hyprctl_keywd "general:border_size" int) != "2" ]]
    then
        hyprctl keyword general:border_size 2
        $eww update look_border=true
    else
        hyprctl keyword general:border_size 0
        $eww update look_border=false
    fi
}   

shadow() {
    if [[ $(hyprctl_keywd "decoration:drop_shadow" int) == "0" ]]
    then
        hyprctl keyword decoration:drop_shadow 1
        $eww update look_shadow=true
    else
        hyprctl keyword decoration:drop_shadow 0
        $eww update look_shadow=false
    fi
}   


case $1 in
    opacity)
        opacity;;
    rounding)
        rounding;;
    border)
        border;;
    shadow)
        shadow;;
esac
