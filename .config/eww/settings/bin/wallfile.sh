#!/usr/bin/env bash

set -eu

file=$(zenity --file-selection --file-filter="Image files | *.png *.jpg *.jpeg *.gif *.bmp *.tiff *.svg"||exit)
if [[ "$(file --dereference --brief --mime-type -- "$file")" == image/* ]]
then
    swww img -t center "$file"
else
    $XDG_CONFIG_HOME/eww/bin/notify.sh "Selected file isn't an image" "Try selecting another file"
fi
