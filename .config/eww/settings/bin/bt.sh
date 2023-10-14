#!/bin/bash

declare -A ICONS=(
[audio-headset]="/usr/share/icons/Tela/scalable/devices/audio-headphones.svg"
[phone]="/usr/share/icons/Tela/scalable/devices/phone.svg"
[audio-card]="/usr/share/icons/Tela/scalable/devices/audio-speakers.svg"
[computer]="/usr/share/icons/Tela/scalable/devices/computer.svg"
[input-gaming]="/usr/share/icons/Tela/scalable/devices/input-gaming.svg"
[input-keyboard]="/usr/share/icons/Tela/scalable/devices/input-keyboard.svg"
[input-mouse]="/usr/share/icons/Tela/scalable/devices/input-mouse.svg"
[fallback]="/usr/share/icons/Tela/scalable/devices/bluetooth.svg"
)
eww_settings="eww -c $HOME/.config/eww/settings"
eww_bar="eww -c $HOME/.config/eww/top-bar"

function update(){
   $eww_settings update "$@" 
}


function power_status(){
    bluetoothctl show|grep -q "Powered: yes"
}

function toggle_power(){
    if power_status
    then
        bluetoothctl power off
    else
        bluetoothctl power on 
    fi
}

function scan_status(){
    bluetoothctl show|grep -q "Discovering: yes"
}

function toggle_scan(){
    if scan_status
    then
        killall "bluetoothctl"
        bluetoothctl scan off
    else
        bluetoothctl scan on & disown
    fi
}

function pair_status(){
    bluetoothctl show|grep -q "Pairable: yes"
}

function toggle_pair(){
    if pair_status
    then
        bluetoothctl pairable off
    else
        bluetoothctl pairable on
    fi
}

function discover_status(){
    bluetoothctl show|grep -q "Discoverable: yes"
}
function toggle_discover(){
    if discover_status
    then
        bluetoothctl discoverable off
    else
        bluetoothctl discoverable on
    fi
}


function list_devices(){
    devices="$(bluetoothctl devices)"
    length=$(echo "$devices"|wc -l)
    line_nr=1
    printf  "["
    echo "$devices"|while read -r _ mac name
    do
        info="$(bluetoothctl info $mac)"
        iconType="$(echo "$info"|grep "Icon: "|cut -d ' ' -f 2-)"
        if [[ "$iconType" == "" ]]
        then
            icon=${ICONS["fallback"]}
        else
            icon=${ICONS[$iconType]}
        fi
        echo "$info"|grep -q "Connected: yes"&&connected=true||connected=false
        echo "$info"|grep -q "Paired: yes"&&paired=true||paired=false
        echo "$info"|grep -q "Trusted: yes"&&trusted=true||trusted=false
        echo "$info"|grep -q "Blocked: yes"&&blocked=true||blocked=false
        printf '{"mac":"%s","name":"%s","icon":"%s","connected":%s,"paired":%s,"trusted":%s,"blocked":%s}' "$mac" "$name" "$icon" "$connected" "$paired" "$trusted" "$blocked"
        if [[ line_nr -ne $length ]]
        then
            printf ","
        fi
        ((line_nr++))
    done
    printf ']'
}
function upd(){
    $eww_settings update bt_search_icon=""
    devs="$(list_devices)"
    power_status&&power=true||power=false
    pair_status&&pairable=true||pairable=false
    scan_status&&scanning=true||scanning=false
    discover_status&&discoverable=true||discoverable=false
    $eww_settings update bt_status="$(printf '{"power":%s,"pairable":%s,"scanning":%s,"discoverable":%s}' $power $pairable $scanning $discoverable)"
    $eww_settings update bt_devices="$devs"
    $eww_settings update bt_connected="$(echo "$devs"|jq 'map(select(.connected == true))')"
    $eww_settings update bt_search_icon="󰑓"
}
case $1 in
    search)
        toggle_scan;;
    upd)
        upd;;
    toggle)
        toggle_$2;;
esac
