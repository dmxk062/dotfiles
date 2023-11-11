#!/bin/bash

eww="eww -c $HOME/.config/eww/top-bar"

create_temp() {
    mkdir -p /tmp/eww/cache/clip
    timestamp="$(date +'%Y_%m.%d_%H:%M:%S_qr')"
    echo "/tmp/eww/cache/clip/${timestamp}.png"
}
choose_region() {
    sleep 0.1
    area=$(slurp -w 0 -b "#4c566acc" -s "#ffffff00")
    sleep 0.5
    echo "$area"
}
close() {
    $eww close screenshot_popup
}
open() {
    $eww open screenshot_popup --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
}

take_sc() {
    file="$(create_temp)"
    region="$(choose_region)"
    if ! grim -g "$region" "$file"
    then
        open
        exit
    fi
    echo "$file"
}

wifi() {
    IFS=';' read -ra fields <<< "$1"
    declare -A map
    for field in "${fields[@]}"
    do
        if [[ $field == "" ]]
        then
            continue
        fi
        IFS=":" read -r key val <<< "$field"
        map["$key"]="$val"
    done
    $eww update qr_data="$(printf '{"type":"wifi","ssid":"%s","password":"%s","algorithm":"%s"}\n' "${map["S"]}" "${map["P"]}" "${map["T"]}")"


}
url(){
    $eww update qr_data="$(printf '{"type":"url","url":"%s"}\n' "$1")"
}

main(){
    close
    file=$(take_sc)
    if [[ $file == "" ]]
    then
        exit
    fi
    contents=$(zbarimg -q "$file")
    if [[ $contents == "" ]]
    then
        $eww update qr_error=true
        $eww update qr_data='{}'
        open
        exit
    else
        $eww update qr_error=false
    fi
    IFS=":" read -r type datatype content <<< "$contents"
    case $datatype in
        WIFI)
            wifi "$content";;
        http|https)
            url "$content";;
        *)
            echo "$datatype";;
    esac
    open

    
}


main "$@"
