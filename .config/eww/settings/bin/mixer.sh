#!/bin/bash
IFS=$'\n'
ICON_THEME="/usr/share/icons/Tela/scalable"
function list(){
SINK_INPUTS="$(pactl --format=json list sink-inputs 2> /dev/null)"  #get rid of the stupid ascii warning
printf "["
length=$(echo $SINK_INPUTS|jq 'length')
i=1
for media in $(echo "$SINK_INPUTS"|jq -c '.[]')
do
    mapfile -t stream <<< "$(echo "$media"|jq -r '.properties."media.name", .index, .properties."application.name"//.properties."node.name", .volume."front-left".value_percent, .mute, .properties."application.process.binary"//null')"
    name=${stream[0]}
    volume=${stream[3]}
    volume=${volume%?}
    icon="${stream[5]}"
    if ! [[ -f "${ICON_THEME}/apps/${icon}.svg" ]]; then # so that all the org.smth.app names work
        if ls "${ICON_THEME}/apps/"*"${icon}.svg" > /dev/null; then
            icon="$(basename "${ICON_THEME}/apps/"*"${icon}.svg")"
            icon="${icon%.*}"
        else
            icon="accessories-media-converter"
        fi
    fi
    if [[ "$name" == "(null)" ]]
    then
        name="$(pactl list sink-inputs|grep "${stream[1]}" -A30|grep media.name|awk -F = '{print $2}')" 
    else
        name=$(printf '"%s"' "$(echo "$name"|sed 's/"/\\"/g')")
    fi
    printf '{"id":%s,"name":%s,"app":"%s","volume":%s, "mute":%s, "icon":"%s"}' "${stream[1]}" "$name" "${stream[2]}" "$volume" "${stream[4]}" "${icon}"
    if ((i != length))
    then
        printf ","
    fi
    ((i++))
done
printf "]"
}
case $1 in
    ls)
        list;;
    *)
        eww -c "$HOME/.config/eww/settings" update streams="$(list)";;
esac
