#!/usr/bin/env bash

monitor_name="$2"
monitor_current_json=$(hyprctl -j monitors|jq --arg name "$monitor_name" '.[]|select(.name == $name)')
mapfile -t options <<< "$(echo "$monitor_current_json"|jq '.width, .height, .x ,.y, .refreshRate, .scale, .transform, .dpmsStatus, .vrr')"
current_x=${options[0]}
current_y=${options[1]}
current_a=${options[2]}
current_b=${options[3]}
current_refresh=${options[4]}
current_scale=${options[5]}
current_transform=${options[6]}
current_dpms=${options[7]}
current_vrr=${options[8]}

case $1 in
    refresh)
        cmdline="${2},${current_x}x${current_y}@${3},${current_a}x${current_b},${current_scale},transform, ${current_transform}"
        echo "$cmdline"
        hyprctl keyword monitor "$cmdline";;
    scale)
        cmdline="${2},${current_x}x${current_y}@${current_refresh},${current_a}x${current_b},${3},transform, ${current_transform}"
        echo "$cmdline"
        hyprctl keyword monitor "$cmdline";;
    resolution)
        for screen in /sys/class/drm/card*
        do
            if [[ "$screen" == "/sys/class/drm/card"*"-${2}" ]]
            then
                file="$screen/modes"
            fi
        done
        if cat "$file"|grep -q "${3}"
        then
            cmdline="${2},${3}@${current_refresh},${current_a}x${current_b},${current_scale},transform, ${current_transform}"
            hyprctl keyword monitor "$cmdline"
        else
            notify-send -u "critical" "Error changing resolution:" "The file ${file} does not contain the video mode ${3}"
        fi;;
    transform)
        cmdline="${2},${current_x}x${current_y}@${current_refresh},${current_a}x${current_b},${current_scale},transform, ${3}"
        hyprctl keyword monitor "$cmdline"
        hyprctl keyword device:wacom-hid-52d3-finger:transform "$3";;
    vrr)
        cmdline="${2},${current_x}x${current_y}@${current_refresh},${current_a}x${current_b},${current_scale},transform, ${current_transform},vrr,${3}"
        hyprctl keyword monitor "$cmdline";;

esac
