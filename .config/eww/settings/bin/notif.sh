#!/bin/bash
#

urgency_names='
[
"low",
"normal",
"urgent"
]
'
notifs='[]'


function update(){
    eww -c $HOME/.config/eww/hud/ update "$@"
}
function update_panel(){
    eww -c $HOME/.config/eww/shell/ update "$@"
}
function handle_event(){
    time=$(date +'%H:%M')
    notifs_new_all=$(makoctl list|jq -Mc --argjson names "$urgency_names" --arg time "$time" '.data|.[]|map({time:$time,id:.id.data,name:."app-name".data,icon:."app-icon".data,title:.summary.data,text:.body.data,type:.category.data,urgency:.urgency.data,level:$names[.urgency.data],"actions":(.actions.data|to_entries | map({"name":.value, "action":.key}))})' |jq 'sort_by(.id)|reverse' -Mc)
    if [[ "$notifs_new_all" == "[]" ]]
    then 
        new_notif_array="[]"
    else
        new_notif_array=$(echo "$notifs $notifs_new_all"|jq -s 'flatten|unique_by(.id)'|jq  '. | to_entries | map(.value + { "index": .key | tonumber })' -Mc)
    fi
    notifs=$new_notif_array
    echo "$notifs"|tee /tmp/.notifs.json

}
function update_count(){
    makoctl list|jq '.data|.[]|length'
}

function monitor(){ 
    [[ -f /tmp/.notifs.json ]]&&touch /tmp/.notifs.json
    dbus-monitor "interface='org.freedesktop.Notifications'" |while read -r line
    do
        if echo "$line"|grep -q "signal"||echo "$line"|grep -q "member="
        then
            temp_notifs="$(handle_event)"
            temp_notifcount="$(update_count)"
            update_panel notifs="$temp_notifs"
            update_panel notif-count="$temp_notifcount"
        fi
    done
}

case $1 in 
    monitor)
        monitor;;
    toggle-mode)
        if [[ "$(makoctl mode)" == "eww_override" ]]
        then
            makoctl mode -r eww_override
            update_panel hide-notif-popups=false
            eww -c "$HOME/.config/eww/settings" update hide-notif-popups=false
        else
            makoctl mode -s eww_override
            update_panel hide-notif-popups=true
            eww -c "$HOME/.config/eww/settings" update hide-notif-popups=true
        fi;;
    upd)
        update_panel notifs="$(handle_event)"
        update_panel notif-count="$(update_count)"
        ;;
esac
