#!/usr/bin/env bash
function notify(){
    msg="$1"
    path="$2"
    notify-send "$msg" -i "$path" -c "screenshot"
}
function select-region(){
    slurp -b "#2e344055" -c "00000000" -s "#4c566a55" -w 0
}
function copy-clip(){
    wl-copy < "$1"
}
function create-temp(){
    mkdir -p /tmp/workspaces_dmx/cache/clip
    timestamp="$(date +'%d.%m_%Y_%H:%M:%S_grim')"
    echo "/tmp/workspaces_dmx/cache/clip/${timestamp}.png"
}
function create-file(){
    dir="$(xdg-user-dir PICTURES)/Screenshots"
    timestamp="$(date +'%d.%m_%Y_%H:%M:%S_grim')"
    echo "${dir}/${timestamp}.png"
}
function select-monitor(){
    monitors="$(hyprctl monitors -j|jq 'map({name:.name,desc:.description})')"
    length=$(($(echo $monitors |jq 'length')-1))
    arglist=""
    for ((i=0;i<=$length;i++))
    do 
        name=$(echo $monitors|jq --argjson index $i -Mcr '.[$index].name')
        arglist="${arglist} --extra-button=$name"
    done
    zenity --question --switch --text="Choose Output" $arglist
}
function monitor-clip(){
    file="$(create-temp)"
    monitor=$(select-monitor)
    sleep 0.4
    if ! grim -o "$monitor" "$file"
    then
        exit
    fi
    copy-clip "$file"
    echo "$file"|xargs -n 1 basename > /tmp/workspaces_dmx/cache/clip/.current.txt
    notify "Copied to Clipboard" "$file"
}
function monitor-file(){
    file="$(create-file)"
    monitor=$(select-monitor)
    sleep 0.4
    if ! grim -o "$monitor" "$file"
    then
        exit
    fi
    notify "Screenshot taken: $(basename $file)" "$file"
}
function select-clip(){
    file="$(create-temp)"
    selection=$(select-region)
    sleep 0.4
    if ! grim -g "$selection" "$file"
    then
        exit
    fi
    copy-clip "$file"
    echo "$file"|xargs -n 1 basename > /tmp/workspaces_dmx/cache/clip/.current.txt
    notify "Copied to Clipboard" "$file"
}
function select-file(){
    file="$(create-file)"
    selection=$(select-region)
    sleep 0.4
    if ! grim -g "$selection" "$file"
    then
        exit
    fi
    notify "Screenshot taken $(basename $file)" "$file"
}
case $1 in 
    monitor)
        monitor-${2};;
    selection)
        select-${2};;
esac
