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
    if file=$(zenity --file-selection --file-filter="Disk Images | *.iso *.img *.bin *.vhd *.squashfs"||exit); then
        udisksctl loop-setup --file=$file
    fi
    $eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')


}

case $1 in 
    remove)
        remove "$2"
        ;;
    add)
        add_image_file 
        ;;

esac