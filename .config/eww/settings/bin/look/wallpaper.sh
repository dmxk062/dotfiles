#!/usr/bin/env bash

eww="eww -c $HOME/.config/eww/settings"

$eww close settings
_exit(){
    $eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
    exit

}

case $1 in
    color)
        answer="$(zenity --color-selection --title="Select a Background Color"|sed -e 's/rgb(//' -e 's/rgba(//' -e 's/)//')"
        [[ -z $answer ]]&&_exit
        IFS=',' read -r r g b <<< $answer
        hex="$(printf "%02X%02X%02X" "$r" "$g" "$b")"
        swww clear $hex
        ;;
    file)
        set -eu

        file=$(zenity --file-selection --file-filter="Image files | *.png *.jpg *.jpeg *.gif *.bmp *.tiff *.svg"||_exit)
        if [[ "$(file --dereference --brief --mime-type -- "$file")" == image/* ]]
        then
            ~/.config/background/wallpaper.sh wall "$file"
        fi
        ;;
esac
_exit


