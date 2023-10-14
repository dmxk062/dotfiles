#!/bin/bash
IFS=$'\n'
function list(){
SINK_INPUTS="$(pactl --format=json list sink-inputs 2> /dev/null)"  #get rid of the stupid ascii warning
printf "["
length=$(echo $SINK_INPUTS|jq 'length')
i=1
for media in $(echo "$SINK_INPUTS"|jq -c '.[]')
do
    mapfile -t stream <<< "$(echo "$media"|jq -r '.properties."media.name", .index, .properties."application.name", .volume."front-left".value_percent, .mute')"
    name=${stream[0]}
    volume=${stream[3]}
    volume=${volume%?}
    if [[ "$name" == "(null)" ]]
    then
        name="$(pactl list sink-inputs|grep "${stream[1]}" -A30|grep media.name|awk -F = '{print $2}')" 
    else
        name=$(printf '"%s"' "$(echo "$name"|sed 's/"/\\"/g')")
    fi
    printf '{"id":%s,"name":%s,"app":"%s","volume":%s, "mute":%s}' "${stream[1]}" "$name" "${stream[2]}" "$volume" "${stream[4]}"
    if ((i != length))
    then
        printf ","
    fi
    ((i++))
done
printf "]"
}
eww -c "$HOME/.config/eww/settings" update streams="$(list)"
