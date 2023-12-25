#!/usr/bin/env bash

set -eu
# manage loop devices from eww

eww="eww -c $XDG_CONFIG_HOME/eww/settings"

remove(){
    path=$1
    udisksctl loop-delete -b "$path"
}

add_image_file(){
    $eww close settings
    if file=$(zenity --title="File Picker" --file-selection --file-filter="Disk Images | *.iso *.img *.bin *.vhd *.squashfs"||exit); then
        udisksctl loop-setup --file=$file
    fi
    $eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
}
add_file_path(){
    udisksctl loop-setup --file="$1"
}

case $1 in 
    remove)
        remove "$2"
        ;;
    add)
        add_image_file 
        ;;
    add_path)
        add_file_path "$2"
        ;;

esac
