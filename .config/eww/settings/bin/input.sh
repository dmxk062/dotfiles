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

function kbd(){
    if [[ $(hyprctl_keywd "input:kb_layout" ) != "us" ]]
    then
        hyprctl keyword input:kb_layout us
        $eww update input_layout="QWERTY US"
    else
        hyprctl keyword input:kb_layout de
        $eww update input_layout="QWERTZ DE"
    fi
}
function left_handed(){
    if [[ $(hyprctl_keywd "input:left_handed" int) != "0" ]]
    then
        hyprctl keyword input:left_handed 0
        $eww update input_left_handed=false
    else
        hyprctl keyword input:left_handed 1
        $eww update input_left_handed=true
    fi
}
function tap_to_click(){
    if [[ $(hyprctl_keywd "input:touchpad:tap-to-click" int) != "1" ]]
    then
        hyprctl keyword input:touchpad:tap-to-click 1
        $eww update input_tap_to_click=true
    else
        hyprctl keyword input:touchpad:tap-to-click 0
        $eww update input_tap_to_click=false
    fi
}
function ws_swipe(){
    if [[ $(hyprctl_keywd "gestures:workspace_swipe " int) != "1" ]]
    then
        hyprctl keyword gestures:workspace_swipe  1
        $eww update input_ws_swipe=true
    else
        hyprctl keyword gestures:workspace_swipe  0
        $eww update input_ws_swipe=false
    fi
}
function natural_scroll(){
    if [[ $(hyprctl_keywd "input:natural_scroll" int) != "0" ]]
    then
        hyprctl keyword input:natural_scroll  0
        $eww update input_natural_scroll=false
    else
        hyprctl keyword input:natural_scroll  1
        $eww update input_natural_scroll=true
    fi
}
function osk(){
    if killall wvkbd
    then
        $eww update input_osk=false
        eww -c "$HOME/.config/eww/shell" update input_osk=false
    else
        $HOME/.local/bin/wvkbd --fn "Torus" --landscape-layers full  &
        $eww update input_osk=true
        eww -c "$HOME/.config/eww/shell/" update input_osk=true
    fi

}

case $1 in
    kbd)
        kbd;;
    left_handed)
        left_handed;;
    tap_click)
        tap_to_click;;
    ws_swipe)
        ws_swipe;;
    natural_scroll)
        natural_scroll;;
    osk)
        osk;;
esac
