#!/usr/bin/env bash

CACHEDIR="$XDG_CACHE_HOME/qr"
[[ ! -d "$CACHEDIR" ]] && mkdir -p "$CACHEDIR"

region="$(slurp -w 0 -b '#4c566acc' -s '#ffffff00')"
sleep 0.1
file="$CACHEDIR/$EPOCHSECONDS.png"

if ! grim -g "$region" "$file"; then
    exit
fi

decoded="$(zbarimg -q "$file")"
rm "$file"
if [[ -z "$decoded" ]]; then
    exit
fi

IFS=":" read -r prefix type data <<< "$decoded"
case "$type" in
    WIFI)
        IFS=";" read -ra fields <<< "$data"
        for field in "${fields[@]}"; do
            if [[ -z "$field" ]]; then continue; fi
            IFS=":" read -r type value <<< "$field"
            case "$type" in
                T) crypt=$value;;
                S) ssid=$value;;
                P) passwd=$value;;
                H) if [[ "$value" == true ]]; then
                    hidden=yes
                else
                    hidden=no
                fi;;
            esac
        done
        reply="$(notify-send "WiFi Network" "$ssid" -i "network-wireless"\
            --action=copy="Copy Password"\
            --action=connect="Connect")"
        case "$reply" in
            copy) wl-copy <<< "$passwd";;
            connect)
                if ! nmcli device wifi connect "$ssid" password "$passwd" hidden "$hidden"; then
                    nmcli connection up "$ssid"
                fi
                ;;
        esac
        ;;
    http|https)
        reply="$(notify-send "Hyperlink" "$type:$data"\
            --action=copy="Copy"\
            --action=open="Open")"
        case "$reply" in 
            copy) wl-copy <<< "$type:$data";;
            open) xdg-open "$type:$data";;
        esac
        ;;
    *)
        reply="$(notify-send "Text" "$type:$data" \
            --action=copy="Copy")"
        if [[ "$reply" == copy ]]; then
            wl-copy <<< "$type:$data"
        fi
esac

