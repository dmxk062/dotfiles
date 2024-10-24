#!/usr/bin/env bash

PROMPT="\0prompt\x1f"
ICON="\0icon\x1f"
ACTIVE="\0active\x1f"
SET_DELIM="\0delim\x1f"
META="\x1fmeta\x1f"
INFO="\x1finfo\x1f"

WORKSPACE_ORDER='{
  "web": 1,
  "web2": 2,
  "web3": 3,
  "web4": 4,
  "main": 10,
  "1": 11,
  "2": 12,
  "3": 13,
  "4": 14,
  "5": 15,
  "6": 16,
  "7": 17,
  "8": 18,
  "9": 19,
  "10": 20,
  "11": 21,
  "12": 22,
  "13": 23,
  "14": 24,
  "15": 25,
  "16": 26,
  "17": 27,
  "18": 28,
  "19": 29,
  "20": 30,
  "21": 31,
  "22": 32,
  "23": 33,
  "24": 34,
  "games": 300,
  "srv": 350,
  "external": 370,
  "mirror": 371,
  "special:1": 400,
  "special:2": 401,
  "special:3": 402,
  "special:4": 403,
  "OVERVIEW": 500
}'



list_windows() {
    hyprctl -j clients \
        | jq -cr --argjson order "$WORKSPACE_ORDER" \
        'map(. + {pos:$order[.workspace.name],})|sort_by(.at[1])|sort_by(.pos)
            |.[]|"\(.title)\t\(.address)\t\(.workspace.id)\t\(.workspace.name)\t\(.class)"' 
}

if ((ROFI_RETV == 0)); then
    active="$(hyprctl -j activewindow|jq -r '.address')"
    echo -en "${SET_DELIM}\t\n"
    echo -en "${PROMPT}Search Windows...\t"
    i=0
    while IFS=$'\t' read -r title address workspace_id workspace_name class; do 
        if [[ "$active" == "$address" ]]; then
            echo -en "${ACTIVE}$i\t"
        fi
        ((i++))
        printf "%s\n%s in %s$ICON%s$INFO%s\t" "${title}" "${class:-$title}" "${workspace_name}" "${class:-"desktop"}" "${address}"
    done < <(list_windows)
else 
    ( hyprctl -- dispatch focuswindow "address:$ROFI_INFO" > /dev/null 2>&1) & disown
fi
