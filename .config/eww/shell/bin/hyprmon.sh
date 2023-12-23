#!/bin/bash

function update(){
    eww -c "$HOME/.config/eww/shell/" update "$@"
}

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
"special:1":400,
"special:2":401,
"special:3":402,
"special:4":403
}'

function get_active_workspace_id(){
    hyprctl activeworkspace -j|jq  '.id'
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
                urgent_win="$addr"
                addr="0x${addr}"
                update urgent_win="${addr}"
                update urgent_ws="$(hyprctl clients -j|jq --arg addr "$addr" '.[]|select(.address == $addr)|.workspace.id')"
                ;;
            submap*)
                IFS=">" read -r _ _ map <<< "$line"
                update hypr_submap="$map"
                # if [[ $map != "" ]]
                # then
                #     $XDG_CONFIG_HOME/eww/shell/popups/bin/submap.sh on
                # else
                #     $XDG_CONFIG_HOME/eww/shell/popups/bin/submap.sh off
                # fi

                ;;
            "activewindowv2>>$urgent_win")
               urgent_win=''
               eww -c $XDG_CONFIG_HOME/eww/shell update urgent_win='' urgent_ws=''
               ;;
            activewindowv2*|closelayer*|openlayer*) # ignore stuff we dont really care about
                continue;;
            changefloatingmode*) # we dont care about workspaces here
                update window="$(hyprctl activewindow -j)"
                ;;
            *)
                update window="$(hyprctl activewindow -j)"
                update workspaces="$(list_workspaces)"
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
