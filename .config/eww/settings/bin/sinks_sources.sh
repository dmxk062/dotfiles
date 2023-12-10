#!/bin/bash

list_sources() {
    pactl --format=json list sources |jq 'map(. + { 
    port: .active_port,
    volume: (if .volume."front-left" != null then .volume."front-left".value_percent|sub("%";"")| tonumber else .volume.mono.value_percent|sub("%";"")|tonumber end),
    mute: .mute,
    icon: .properties."device.icon_name",
    ports: (.ports | map(
        {name: .name,
        desc: .description,
        type: .type,
        avail: .availability
        }
                        )
            )
    })'|jq -Mc 'map({name:.description,id:.name,ports: .ports,port: .port, volume: .volume, mute: .mute, icon: .icon})'|jq -Mc --arg id "$(pactl get-default-source)" 'map(. + {active: (if .id == $id then true else false end)})'
}
list_sinks() {
pactl --format=json list sinks |jq 'map(. + { 
port: .active_port,
volume: .volume."front-left".value_percent|sub("%";"")| tonumber,
mute: .mute,
icon: .properties."device.icon_name",
ports: (.ports | map(
    {name: .name,
    desc: .description,
    type: .type,
    avail: .availability
    }
                    )
        )
})'|jq -Mc 'map({name:.description,id:.name,ports: .ports,port: .port, volume: .volume, mute: .mute, icon: .icon})'|jq -Mc --arg id "$(pactl get-default-sink)" 'map(. + {active: (if .id == $id then true else false end)})'
}

set_source(){
    pactl set-default-source $1
}
set_sink(){
    pactl set-default-sink $1
}
update(){
    eww -c $HOME/.config/eww/settings update "$@"&
    eww -c $HOME/.config/eww/shell update "$@"&
}
case $1 in
    upd)
        update "${2}=$(list_${2})"
        update "active_${2}=$(list_${2}|jq '.[]|select(.active == true)')"
        update "${2}-icons=$(list_${2}|jq '.[]|select(.active == true)|.icon')";;
    list)
        list_${2};;
    upd_active)
        update "active_${2}=$(list_${2}|jq '.[]|select(.active == true)')";;
    list_active)
        list_${2}|jq '.[]|select(.active == true)';;

esac
