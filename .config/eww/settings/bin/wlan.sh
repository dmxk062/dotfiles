#!/bin/bash

eww_settings="eww -c $HOME/.config/eww/settings"
eww_bar="eww -c $HOME/.config/eww/top-bar"

function status(){
    if [[ $(nmcli radio wifi) == "enabled" ]]
    then    
        return 0
    else
        return 1
    fi
}
function wifi_power(){
    nmcli radio wifi "$1"
}

function toggle_state(){
    if status
    then
        wifi_power off
        $eww_settings update wlan_power=false
    else
        wifi_power on
        $eww_settings update wlan_power=true
    fi
}

function list_wlans(){
    $eww_settings update wifi_search_icon=""
    nmcli device wifi rescan
    nmcli -g IN-USE,SIGNAL,SECURITY,SSID dev wifi list|while read -r line
    do
        IFS=':' read -ra fields <<< "$line"
        [[ "${fields[0]}" == '*' ]]&&active=true||active=false
        [[ "${fields[2]}" != "" ]]&&passwd=true||passwd=false
        if [[ ${fields[1]} -gt 90 ]]
        then
            strength_icon="󰤨"
        elif [[ ${fields[1]} -gt 70 ]]
        then
            strength_icon="󰤥"
        elif [[ ${fields[1]} -gt 50 ]]
        then
            strength_icon="󰤢"
        elif [[ ${fields[1]} -gt 30 ]]
        then
            strength_icon="󰤟"
        else 
            strength_icon="󰤯"
        fi
        if [[ "${fields[3]}" != "" ]]
        then
            printf '{"ssid":"%s","strength":%s,"security":"%s","password":%s,"active":%s,"strength_icon":"%s"}' "${fields[3]}" "${fields[1]}" "${fields[2]}" "$passwd" "$active" "$strength_icon"
        fi
    done
    IFS=$' \t\n'
    $eww_settings update wifi_search_icon="󰑓"

}

function connect(){
    ssid="$1"
    sec=$2
    passwd="$3"
    if $sec
    then 
        if ! nmcli device wifi connect "$ssid" password "$passwd"
        then
            notify-send -c "wifi-error" -u "critical" "Failed to connect to $ssid. Wrong password?"
        else
            notify-send -c "wifi" -u "normal" "Now Connected to $ssid"
            $eww_settings update wifi_password_reveal=false
            $eww_settings update wifi_passwd=""
            $eww_settings update connect_ssid=""
        fi
    else
        if ! nmcli device wifi connect "$ssid"
        then
            notify-send -c "wifi-error" -u "critical" "Failed to connect to $ssid. Weak connection?"
        else
            notify-send -c "wifi" -u "normal" "Now Connected to $ssid"
            $eww_settings update wifi_password_reveal=false
            $eww_settings update wifi_passwd=""
            $eww_settings update connect_ssid=""
        fi
    fi
}
function genqr(){
    if ! status; then return; fi
    SSID="$(nmcli device wifi show-password|grep "SSID:"|cut -d ' ' -f 2)"
    SEC="$(nmcli device wifi show-password|grep "Security:"|cut -d ' ' -f 2)"
    PASSWD="$(nmcli device wifi show-password|grep "Password:"|cut -d ' ' -f 2)"
    path="/tmp/workspaces_dmx/cache/$SSID.qr.png"
    qrencode -s 6 -l H -o "$path" "WIFI:T:$SEC;S:$SSID;P:$PASSWD;;" --foreground=2E3440 --background=ECEFF4 
    echo $path

}
listen(){
        if [[ ${fields[4]} -gt 90 ]]
        then
            strength_icon="󰤨"
        elif [[ ${fields[4]} -gt 70 ]]
        then
            strength_icon="󰤥"
        elif [[ ${fields[4]} -gt 50 ]]
        then
            strength_icon="󰤢"
        elif [[ ${fields[4]} -gt 30 ]]
        then
            strength_icon="󰤟"
        else 
            strength_icon="󰤯"
        fi
    if status
    then
        $eww_settings update wlan_power=true
        qrpath="$(genqr)"
    else
        $eww_settings update wlan_power=false
        qrpath=""
        strength_icon="󰤭"
    fi
    mapfile -t -d ':' fields  <<< "$(nmcli -g IN-USE,SSID,SIGNAL,SECURITY,SIGNAL dev wifi list|grep '*')"
    $eww_settings update wifi_status="$(printf '{"ssid":"%s","sec":"%s","strength":"%s","qrpath":"%s","icon":"%s"}' "${fields[1]}" "${fields[3]}" "${fields[2]}" "$qrpath" "$strength_icon")"
    nmcli m|while read -r line 
    do
        mapfile -t -d ':' fields  <<< "$(nmcli -g IN-USE,SSID,SIGNAL,SECURITY,SIGNAL dev wifi list|grep '*')"
        if [[ ${fields[4]} -gt 90 ]]
        then
            strength_icon="󰤨"
        elif [[ ${fields[4]} -gt 70 ]]
        then
            strength_icon="󰤥"
        elif [[ ${fields[4]} -gt 50 ]]
        then
            strength_icon="󰤢"
        elif [[ ${fields[4]} -gt 30 ]]
        then
            strength_icon="󰤟"
        else 
            strength_icon="󰤯"
        fi
    if status
    then
        $eww_settings update wlan_power=true
        qrpath="$(genqr)"
    else
        $eww_settings update wlan_power=false
        qrpath=""
        strength_icon="󰤭"
    fi
        $eww_settings update wifi_status="$(printf '{"ssid":"%s","sec":"%s","strength":"%s","qrpath":"%s","icon":"%s"}' "${fields[1]}" "${fields[3]}" "${fields[2]}" "$qrpath" "$strength_icon")"
    done
}
case $1 in
    upd)
        $eww_settings update wlans="$(list_wlans|jq -s 'unique_by(.ssid)|sort_by(.strength)|reverse')";;
    toggle)
        toggle_state;;
    status)
        if status
        then
            $eww_settings update wlan_power=true
        else
            $eww_settings update wlan_power=false
        fi;;
    connect)
        connect "$2" "$3" "$4";;
    listen)
        listen;;
    

esac

