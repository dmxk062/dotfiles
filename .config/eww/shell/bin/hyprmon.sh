#!/bin/bash

function update(){
    eww -c "$HOME/.config/eww/shell/" update $@
}

NOTIFID=1000
LAST_URGENT=""
SUBMAP_ICON="/usr/share/icons/Tela/scalable/apps/preferences-desktop-theme-windowdecorations.svg"

workspace_order='{
"web":1,
"web2":2,
"web3":3,
"web4":4,
"main":10,
"1":11,
"2":12,
"3":13,
"4":14,
"5":15,
"6":16,
"7":17,
"8":18,
"9":19,
"10":20,
"11":21,
"12":22,
"13":23,
"14":24,
"15":25,
"16":26,
"17":27,
"18":28,
"19":29,
"20":30,
"21":31,
"22":32,
"23":33,
"24":34,
"games":300,
"srv":350,
"external":370,
"mirror":371,
"special:1":400,
"special:2":401,
"special:3":402,
"special:4":403,
"OVERVIEW":500
}'

function get_active_workspace_id(){
    hyprctl activeworkspace -j|jq  '.id'
}

function notify_urgent(){
    addr="0x$1"
    IFS=$'\t' read -r title class <<< "$(hyprctl -j clients| jq -r --arg addr "$addr" '.[]|select(.address == $addr)|.title,.class'|tr '\n' '\t')"
    response="$(notify-send -a "$class" -i "$class" \
        "$class demands attention" \
        --transient \
        --action="focus"="Go to Window" \
        "$title")"
    if [[ "$response" == "focus" ]]; then
        hyprctl dispatch focuswindow "address:${addr}"
    fi
}

function list_workspaces(){
        active=$(get_active_workspace_id)
        hyprctl workspaces -j|jq --argjson order "$workspace_order" --argjson activeid "$active" 'map({
            id:.id,
            name:.name,
            display:.monitor,
            count:.windows,
            title:.lastwindowtitle,
            fullscreen:.hasfullscreen,
            pos:$order[.name],
            special:(if .name | test("special:.*") then true else false end),
            active:(if .id == $activeid then true else false end)
        })'|jq -Mc 'sort_by(.pos)'

}

function monitor_changes(){
    update window="$(hyprctl activewindow -j)"
    update workspaces="$(list_workspaces)"
    socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - |while read -r line;
    do
        case "$line" in
            urgent*)
                IFS=">" read -r _ _ addr <<< "$line"
                # hyprctl dispatch focuswindow "address:0x${addr}"
                if [[ "$addr" == "$LAST_URGENT" ]]; then
                    continue
                else
                    LAST_URGENT="$addr"
                    notify_urgent "$addr"&
                fi
                ;;
            submap*)
                IFS=">" read -r _ _ map <<< "$line"
                update hypr_submap="$map"
                if [[ "$map" == "" ]]; then
                    NOTIFID=$(notify-send "Exited Submap" \
                        -i "$SUBMAP_ICON" \
                        --transient \
                        -a "eww_submap" -r $NOTIFID -p "" -t 500)
                else
                    NOTIFID=$(notify-send "Entered Submap" \
                        -i "$SUBMAP_ICON" \
                        --transient \
                        -a "eww_submap" -r $NOTIFID -p "$map")
                fi

                ;;
            'openlayer>>gtk-layer-shell') # this is for nwg-look
                # old_layer_blur="$(hyprctl getoption decoration:blur:xray -j|jq '.set')"
                hyprctl keyword decoration:blur:xray true
            ;;
            'closelayer>>gtk-layer-shell')
                hyprctl keyword decoration:blur:xray false
            ;;
            activewindowv2*|closelayer*|openlayer*) # ignore stuff we dont really care about
                continue;;

            changefloatingmode*) # we dont care about workspaces here
                update window="$(hyprctl activewindow -j)"
                ;;
            "renameworkspace"*"OVERVIEW")
                IFS=">" read -r _ _ val <<< "$line"
                IFS="," read -r overview_id _ <<< "$val"
                eww -c $XDG_CONFIG_HOME/eww/shell/ update overview=true
                $XDG_CONFIG_HOME/hypr/plugins/overview.sh enter&
                ;;
            "renameworkspace>>$overview_id,"*)
                eww -c $XDG_CONFIG_HOME/eww/shell/ update overview=false
                overview_id=""
                $XDG_CONFIG_HOME/hypr/plugins/overview.sh off&
                ;;
            # openwindow*|closewindow*|movewindow*)
            #     eww -c $XDG_CONFIG_HOME/eww/shell update windows="$(hyprctl -j clients|jq --argjson order "$workspace_order" 'map(. + {pos:$order[.workspace.name],})|sort_by(.pos)')"
            #     ;&

                
            *)
                eww -c $XDG_CONFIG_HOME/eww/shell update window="$(hyprctl activewindow -j)" workspaces="$(list_workspaces)"
        esac

    done
}

function switch_to_workspace(){
    id=$1
    name=$2
    workspaces="$(list_workspaces)"
    if ! echo "$workspaces"|jq -e --argjson id "$id" '.[]|select(.id == $id)|.active'
    then
        hyprctl dispatch workspace "$name"
    fi

}


case $1 in 
    monitor)
        monitor_changes;;
    switch)
        switch_to_workspace "$2" "$3";;
    display)
        display_changes;;

esac
