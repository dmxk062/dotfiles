#!/usr/bin/env bash

function list_devices {
    buffer=""
    { while read -r _ mac dname; do
        battery=""
        if [[ -z "$buffer" ]]; then
            buffer="["
        else
            buffer="${buffer},"
        fi

        while read -r field value; do
            case "$field" in
                Icon:) icon="$value";;
                Alias:) alias="$value";;
                Name:) name="$value";;
                Connected:) connected="$value";;
                Paired:) paired="$value";;
                Trusted:) trusted="$value";;
                Blocked:) blocked="$value";;
                Battery*) battery="$(sed -n 's/.*(\([0-9]*\))/\1/p' <<< "$value")";;
            esac
        done < <(bluetoothctl info "$mac")

        [[ "$connected" == "yes" ]]&&connected=true||connected=false
        [[ "$paired" == "yes" ]]&&paired=true||paired=false
        [[ "$trusted" == "yes" ]]&&trusted=true||trusted=false
        [[ "$blocked" == "yes" ]]&&blocked=true||blocked=false

        if [[ -z "$battery" && "$connected" == false ]]; then
            battery=null
        fi

        printf -v buffer '%s{"mac":"%s","name":"%s","alias":"%s","icon":"%s","connected":%s,"paired":%s,"trusted":%s,"blocked":%s,"battery":%s}' \
            "$buffer" "$mac" "$name" "$alias" "$icon" $connected $paired $trusted $blocked $battery
    done < <(bluetoothctl devices)
    echo "$buffer]"
}| jq 'sort_by(.connected | not)'
}

function get_meta {
    while read -r key value; do
        case $key in
            Powered:) powered="$value";;
            Discoverable:) discoverable="$value";;
            Pairable:) pairable="$value";;
            Discovering:) scanning="$value";;
        esac
    done < <(bluetoothctl show)
    [[ "$powered" == "yes" ]]&&powered=true||powered=false
    [[ "$discoverable" == "yes" ]]&&discoverable=true||discoverable=false
    [[ "$pairable" == "yes" ]]&&pairable=true||pairable=false
    [[ "$scanning" == "yes" ]]&&scanning=true||scanning=false

    printf '{"powered":%s,"visible":%s,"pairable":%s,"scanning":%s}\n' \
        $powered $discoverable $pairable $scanning
}

case $1 in
    poll)
        list_devices 
        ;;
    sync)
        eww -c "$XDG_CONFIG_HOME/sway/eww/shell/" update "bt-devices"="$(list_devices)"
        ;;
    poll-meta)
        get_meta
        ;;
    sync-meta)
        eww -c "$XDG_CONFIG_HOME/sway/eww/shell/" update "bt-meta"="$(get_meta)"
        ;;
    sync-all)
        eww -c "$XDG_CONFIG_HOME/sway/eww/shell/" update "bt-meta"="$(get_meta)" "bt-devices"="$(list_devices)"
        ;;
esac
