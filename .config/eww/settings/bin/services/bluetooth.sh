#!/usr/bin/env bash

update(){
    eww -c $XDG_CONFIG_HOME/eww/settings/ update "$1"="$2"
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
    if $battery_present; then
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




monitor(){
# listen for changes via bluetoothctl
# since it does use ansii escapes, we remove them


bluetoothctl --monitor| while read -r line; do
        line="$(echo "$line"|sed "s,\x1B\[[0-9;]*[a-zA-Z],,g")"
        read -r prefix event data <<< "$line"
        if [[ "$prefix" != '['* ]]; then
            continue
        fi
        case $event in
            '[NEW]') list_devices;;
            '[CHG]') echo "$data";;
            *) echo "$event";;
        esac

done



}

monitor
