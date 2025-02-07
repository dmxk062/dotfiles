#!/usr/bin/env bash

EWW="$XDG_CONFIG_HOME/sway/eww/shell"

function get_active {
    nmcli -g TYPE,ACTIVE,UUID,NAME connection show \
        |awk -F":" '
            $1 == "wireguard" && $2 == "yes" {
                printf "{\"active\": true, \"name\":\"%s\", \"uuid\":\"%s\"}\n",$4,$3;
                fflush();
                exit 1;
            }' && echo '{"active": false, "name": "", "uuid": ""}'
}

function list_vpns {
    nmcli -g TYPE,ACTIVE,UUID,NAME connection show \
        |while IFS=":" read -r type active uuid name; do
            if [[ "$type" != "wireguard" ]]; then
                continue
            fi

            if [[ "$active" == "yes" ]]; then
                bactive=true
            else
                bactive=false
            fi

            printf '{"active":%s,"name":"%s","uuid":"%s"}\n' \
                "$bactive" "$name" "$uuid"
            done|jq -s 'sort_by(.name)'
}

case "$1" in
    listen)
        get_active
        nmcli monitor | while read -r _; do get_active; done 
        ;;
    list)
        list_vpns
        ;;
esac
