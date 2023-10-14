#!/usr/bin/env bash

LAUNCHERPATH="$HOME/Games/Minecraft/prismlauncher_instances"

function notify(){
    notify-send "$1" "$2"  --icon="/usr/share/icons/hicolor/scalable/apps/org.prismlauncher.PrismLauncher.svg" --app-name="rofi_minecraft"
}

if ! command -v "prismlauncher"
then
    notify "PrismLauncher not installed" "No executable named prismlauncher found, exiting "
    exit 1
fi
declare -a instances
for instance in $LAUNCHERPATH/*
do
    instname=`basename "$instance"`
    instances+=("$instname")
done


selected=`for instance in "${instances[@]}"
do
    echo "$instance"
done|rofi -dmenu`

notify "Launching $selected"
prismlauncher --launch "$selected"& disown
