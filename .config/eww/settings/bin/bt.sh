#!/bin/bash

eww_settings="eww -c $HOME/.config/eww/settings"

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
        dbus-send --system --type=method_call --dest=org.bluez /org/bluez/hci0 org.bluez.Adapter1.StopDiscovery
    else
        bluetoothctl scan on & disown
        dbus-send --system --type=method_call --dest=org.bluez /org/bluez/hci0 org.bluez.Adapter1.StartDiscovery
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
        deviceName="$(echo "$info"|grep "Name: "|cut -d ' ' -f 2-)"
        echo "$info"|grep -q "Connected: yes"&&connected=true||connected=false
        echo "$info"|grep -q "Paired: yes"&&paired=true||paired=false
        echo "$info"|grep -q "Trusted: yes"&&trusted=true||trusted=false
        echo "$info"|grep -q "Blocked: yes"&&blocked=true||blocked=false
        echo "$info"|grep -q "Battery"&&battery_present=true||battery_present=false
        if [[ $battery_present == true && $connected == true ]]; then
            battery_level="$(echo "$info"|grep "Battery Percentage" | cut -d ' ' -f 4-| sed 's/(\|)//g')"
        else
            battery_level="null"
        fi
        printf '{"mac":"%s","name":"%s","originalName":"%s","icon":"%s","connected":%s,"paired":%s,"trusted":%s,"blocked":%s,"hasBattery":%s,"battery":%s}' "$mac" "$name" "$deviceName" "$iconType" "$connected" "$paired" "$trusted" "$blocked" "$battery_present" "$battery_level"
        if [[ line_nr -ne $length ]]
        then
            printf ","
        fi
        ((line_nr++))
    done
    printf ']'
}
function upd(){
    $eww_settings update bt_search=true
    devs="$(list_devices)"
    power_status&&power=true||power=false
    pair_status&&pairable=true||pairable=false
    scan_status&&scanning=true||scanning=false
    discover_status&&discoverable=true||discoverable=false
    $eww_settings update bt_status="$(printf '{"power":%s,"pairable":%s,"scanning":%s,"discoverable":%s}' $power $pairable $scanning $discoverable)" bt_devices="$devs" bt_connected="$(echo "$devs"|jq 'map(select(.connected == true))')" bt_search=false
}
case $1 in
    search)
        toggle_scan;;
    upd)
        upd;;
    toggle)
        toggle_$2;;
    rename)
        shift
        mac="$1"
        name="$2"
        oldname="$3"
        if [[ "$name" == "" ]]; then
            name="$oldname"
        fi
        bt-device --set "$mac" Alias "$name"
        sleep 0.1
        upd
        ;;
esac
