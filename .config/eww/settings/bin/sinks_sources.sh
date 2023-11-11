#!/bin/bash
icons_out='{
"headset":{
    "muted":"󰟎",
    "unmuted":"󰋋"
},
"audio-headset":{
    "muted":"󰟎",
    "unmuted":"󰋋"
},
"audio-headset-bluetooth":{
    "muted":"󰗿",
    "unmuted":"󰗾"
},
"audio-card-analog-pci":{
    "muted":"󰓄",
    "unmuted":"󰓃"
},
"audio-headset-analog-usb":{
    "muted":"󰟎",
    "unmuted":"󰋋"
},
"speaker":{
    "muted":"󰓄",
    "unmuted":"󰓃"
}
}'
icons_in='{
"headset":{
    "muted":"󰋐",
    "unmuted":"󰋎"
},
"audio-headset-analog-usb":{
    "muted":"󰋐",
    "unmuted":"󰋎"
},
"audio-headset":{
    "muted":"󰋐",
    "unmuted":"󰋎"
},
"audio-headset-bluetooth":{
    "muted":"󰋐",
    "unmuted":"󰋎"
},
"audio-card-analog-pci":{
    "muted":"󰢮",
    "unmuted":"󰢮"
},
"microphone":{
    "muted":"",
    "unmuted":""
}
}'

icons_out_g='{
"headset":"scalable/devices/audio-card.svg",
"audio-headset":"scalable/devices/audio-headphones.svg",
"audio-headset-bluetooth":"scalable/devices/audio-headphones.svg",
"audio-card-analog-pci":"scalable/devices/audio-speakers.svg",
"audio-headset-analog-usb":"scalable/devices/audio-headphones.svg",
"speaker":"scalable/devices/audio-speakers.svg"}'
icons_in_g='{
"headset":"scalable/devices/audio-headphones.svg",
"audio-headset-analog-usb":"scalable/devices/audio-headphones.svg",
"audio-headset":"scalable/devices/audio-headphones.svg",
"audio-headset-bluetooth":"scalable/devices/audio-headphones.svg",
"audio-card-analog-pci":"scalable/devices/audio-card.svg",
"microphone":"scalable/devices/audio-input-microphone.svg"
}'
icons_port='{
"analog-input-front-mic":"",
"analog-input-rear-mic":"",
"analog-input-mic":"",
"[Out] Speaker":"󰓃",
"[Out] Headphones":"󰋋",
"[In] Mic2":"",
"[In] Mic1":"",
"analog-input-linein":"󱡬",
"analog-output-lineout":"󱡬",
"analog-output-headphones":"󰋋",
"headset-output":"󰋋",
"analog-output":"󱡫",
"hdmi-output-0":"󰽟",
"hdmi-output-1":"󰽟",
"hdmi-output-2":"󰽟",
"hdmi-output-3":"󰽟"
}'

list_sources() {
    pactl --format=json list sources |jq --argjson icons "$icons_in" --argjson icons_g "$icons_in_g" --argjson icons_port "$icons_port" 'map(. + { icon: (if .properties."device.icon_name" == null 
then $icons["microphone"] 
else $icons[.properties."device.icon_name"] end),
icon_g: (if .properties."device.icon_name" == null 
then $icons_g["speaker"] 
else $icons_g[.properties."device.icon_name"] end),
port: .active_port,
volume: (if .volume."front-left" != null then .volume."front-left".value_percent|sub("%";"")| tonumber else .volume.mono.value_percent|sub("%";"")|tonumber end),
mute: .mute,
ports: (.ports | map({name: .name,
    desc: .description,
    type: .type,
    avail: .availability,
    icon: $icons_port[.name]}))})'|jq -Mc 'map({name:.description,id:.name,icon:.icon, icon_g: .icon_g,ports: .ports,port: .port, volume: .volume, mute: .mute})'|jq -Mc --arg id "$(pactl get-default-source)" 'map(. + {active: (if .id == $id then true else false end)})'

}
list_sinks() {
pactl --format=json list sinks |jq --argjson icons "$icons_out" --argjson icons_g "$icons_out_g" --argjson icons_port "$icons_port" 'map(. + { icon: (if .properties."device.icon_name" == null 
then $icons["speaker"] 
else $icons[.properties."device.icon_name"] end),
icon_g: (if .properties."device.icon_name" == null 
then $icons_g["speaker"] 
else $icons_g[.properties."device.icon_name"] end),
port: .active_port,
volume: .volume."front-left".value_percent|sub("%";"")| tonumber,
mute: .mute,
ports: (.ports | map({name: .name,
    desc: .description,
    type: .type,
    avail: .availability,
    icon: $icons_port[.name]}))})'|jq -Mc 'map({name:.description,id:.name,icon:.icon, icon_g: .icon_g,ports: .ports,port: .port, volume: .volume, mute: .mute})'|jq -Mc --arg id "$(pactl get-default-sink)" 'map(. + {active: (if .id == $id then true else false end)})'
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
    set)
        set_${2} $3
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
