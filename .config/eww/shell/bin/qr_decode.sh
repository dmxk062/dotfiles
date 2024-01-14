#!/usr/bin/env bash


CACHE_DIR="/tmp/eww/cache/qr"

update(){
    eww -c $XDG_CONFIG_HOME/eww/shell update "$1"="$2"
}
update_many(){
    eww -c $XDG_CONFIG_HOME/eww/shell update "$@"
}

popup(){
    if [[ "$1" == "open" ]]; then
        eww -c $XDG_CONFIG_HOME/eww/shell "open" screenshot_popup --screen "$(hyprctl monitors -j|jq '.[]|select(.focused)|.id')"
    else
        eww -c $XDG_CONFIG_HOME/eww/shell "close" screenshot_popup
    fi
}

get(){
    eww -c $XDG_CONFIG_HOME/eww/shell get "$1"
}

choose_region() {
    sleep 0.1
    area=$(slurp -w 0 -b "#4c566acc" -s "#ffffff00")
    sleep 0.5
    echo "$area"
}

scan_code(){
    timestamp="$(date +'%Y_%m.%d_%H:%M:%S_qr')"
    path="${CACHE_DIR}/${timestamp}.png"
    region="$(choose_region)"
    if ! grim -g "$region" "$path"; then
        exit 1
    fi
    echo "$path"

}

decode_qr(){
    path="$1"
    if ! raw="$(zbarimg -q "$path")"; then 
        exit 1
    fi
    if [[ "$raw" == "" ]]; then
        exit 1
    fi
    content="$(echo "$raw"|head -n1| tr -dc '[:print:]')"
    raw="${raw/QR-Code:}"
    IFS=":" read -r type data <<< "$content"
    case $type in
        QR-Code)
            format="qr"
            ;;
        Codabar|CODE-*|DataBar|EAN-*)
            format="bar"
            ;;
        *)
            format="misc"
            ;;
    esac
    if [[ "$format" != "qr" ]]; then
        printf '{"path":"%s","type":"%s","encoding":"%s", "data": {"type":"text", "str":"%s"}}\n' "$path" "$format" "$type" "$data"
        return
    fi
    IFS=":" read -r contentType data_np <<< "$data"
    case $contentType in
        http*)
            printf '{"path":"%s","type":"%s", "encoding":"%s", "data":{"type":"web","str":"%s"}}' "$path" "$format" "$type" "$data"
            exit
            ;;
        WIFI)
            IFS=";" read -ra fields <<< "$data_np"
            for field in "${fields[@]}"; do
                case $field in 
                    S*)
                        ssid="${field:2}";;
                    T*)
                        sectype="${field:2}";;
                    P*)
                        passwd="${field:2}";;
                    H*)
                        hidden="${field:2}";;
                esac
            done
            if [[ "$sectype" == "nopass" ]] || [[ "$passwd" == "" ]]; then
                passwdRequired=false
            else
                passwdRequired=true
            fi
            printf '{"path":"%s","type":"%s", "encoding":"%s", "data":{"type":"wifi", "ssid":"%s", "security":"%s", "passwd":"%s", "passwdRequired":%s, "hidden":%s}}' \
               "$path" "$format" "$type" "$ssid" "$sectype" "$passwd" "$passwdRequired" "${hidden:-false}"
            ;;
        BEGIN)
            if ! [[ "$data" == "BEGIN:VCARD" ]]; then
                exit 1
            fi
            while IFS= read -r line; do
                case $line in 
                    VERSION:*)
                        version="${line:8}";;
                    FN:*)
                        name="${line:3}";;
                    N:*)
                        IFS=";" read -r lastname firstname <<< "${line:2}";;
                    TITLE:*)
                        title="${line:5}";;
                esac
            done <<< "$raw"
            echo "$raw" >> "${path}.vcs"
            printf '{"path":"%s","type":"%s", "encoding":"%s", "data":{"type":"contact", "version":"%s", "name":"%s", "firstname":"%s", "lastname":"%s", "title":"%s", "path":"%s"}}' \
                "$path" "$format" "$type" "$version" "$name" "$firstname" "$lastname" "$title" "${path}.vcs"
            exit
            ;;
        mailto)
            addr="${data/mailto:}"
            printf '{"path":"%s","type":"%s", "encoding":"%s", "data":{"type":"email", "str":"%s"}}' "$path" "$format" "$type" "$addr"
            ;;

        *)
            printf '{"path":"%s","type":"%s", "encoding":"%s", "data":{"type":"text", "str":"%s"}}' "$path" "$format" "$type" "$data"
            exit
    esac
    

}

popup close
sleep 0.1

if ! qr_data="$(scan_code)"; then
    update_many screenshot_section=2 qr_error=true qr_error_msg="Selection aborted"
    popup open
    exit 1
fi

if ! result="$(decode_qr "$qr_data")"; then
    popup open
    update_many screenshot_section=2 qr_error=true qr_error_msg="No recognized code format found in the selection"
    exit 2
fi

old_lines="$(get qr_data)"
new_lines="$(echo "$old_lines"|jq --argjson new "$result" '. |= [$new] + .')"
update_many screenshot_section=2 qr_error=false qr_error_msg='' qr_data="$new_lines"
popup open

