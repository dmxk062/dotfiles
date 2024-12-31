#!/usr/bin/env bash

DATEFMT="%Y_%m.%d_%H:%M:%S_sc"
VIDEO_DIR="$(xdg-user-dir "VIDEOS")/Recordings"

function create_file {
    timestamp="$(date +"$DATEFMT")"
    REPLY="$VIDEO_DIR/${timestamp}_rec.mkv"
}

if [[ "$1" == "start" ]]; then
    if pkill wf-recorder; then
        exit
    fi
    screen="$(swaymsg -t get_outputs | jq -r '.[]|select(.focused).name')"
    if [[ "$2" == "select" ]]; then
        region="$(slurp -w 0 -b '#4c566acc' -s '#ffffff00')"
        if [[ -z "$region" ]]; then
            exit
        fi
        extra="-g"
        sleep 0.1
    fi

    create_file
    path="$REPLY"
    echo "$region"
    wf-recorder -o $screen  $extra "$region" -c hevc_vaapi -d /dev/dri/renderD128 -f "$path" -r 60 &
    pid=$!
    printf -v struct '{"start":%s, "pid":%s, "path":"%s"}' $EPOCHSECONDS $pid "$path"
    eww -c "$XDG_CONFIG_HOME/sway/eww/shell/" update recording=true recording-info="$struct"

    wait $pid
    eww -c "$XDG_CONFIG_HOME/sway/eww/shell/" update recording=false recording-info='{}'
    reply="$(notify-send "Finished recording video" "$path"\
        --action=open="Open"\
        --action=del="Delete"\
        --action=copy="Copy"\
    )"
    case "$reply" in 
        open) xdg-open "$path";;
        del) rm "$path";;
        copy) wl-copy < "$path";;
    esac
fi

