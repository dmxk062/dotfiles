#!/usr/bin/env bash

update(){
    eww -c $XDG_CONFIG_HOME/eww/shell update "$1"="$2"
}

popup(){
    if [[ "$1" == "open" ]]; then
        eww -c $XDG_CONFIG_HOME/eww/shell "open" screenshot_popup --screen "$(hyprctl monitors -j|jq '.[]|select(.focused)|.id')"
    else
        eww -c $XDG_CONFIG_HOME/eww/shell "close" screenshot_popup
    fi
}

get(){
    eww -c $XDG_CONFIG_HOME/eww/shell get "$1"
}

pick_color(){
    flags="-n -f rgb"
    if ! $ZOOM; then
        flags="$flags -z"
    fi
    if $FREEZE; then
        flags="$flags -r"
    fi

    hyprpicker $flags
}

popup close
sleep 0.6
color="$(pick_color)"
if [[ "$color" == "" ]]; then
    popup open
    exit 1
fi

read -r r g b <<< "$color"
hex=$(printf "#%02X%02X%02X" "$r" "$g" "$b")
new="$(printf '{"r":%s,"g":%s,"b":%s,"hex":"%s"}' $r $g $b $hex)"
old="$(get colorpicker_colors)"
updated="$(echo "$old"|jq --argjson new "$new" '. |= [$new] + .')"
update colorpicker_colors "$updated"
update screenshot_section 3
popup open
