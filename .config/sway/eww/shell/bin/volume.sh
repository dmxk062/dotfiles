#!/usr/bin/env bash

NOTIFICATION_ID="1867"

JQ_QUERY='
.[]|select(.name == $default)|
        "\(.index)\t\(.description)\t\(.properties."device.icon_name")"'

update_out() {
    read OUTMUTE OUTVOL < <(pamixer --get-mute --get-volume)
}
update_in(){
    read INMUTE INVOL < <(pamixer --default-source --get-mute --get-volume)
}
update_names() {
    DEFAULT_SINK_NAME="$(pactl get-default-sink)"
    DEFAULT_SOURCE_NAME="$(pactl get-default-source)"

    IFS=$'\t' read -r DEFAULT_SINK DEFAULT_SINK_DESC DEFAULT_SINK_ICON < <(pactl --format=json list sinks|\
        jq -r --arg default "$DEFAULT_SINK_NAME" "$JQ_QUERY")

    IFS=$'\t' read -r DEFAULT_SOURCE DEFAULT_SOURCE_DESC DEFAULT_SOURCE_ICON < <(pactl --format=json list sources|\
        jq -r --arg default "$DEFAULT_SOURCE_NAME" "$JQ_QUERY")
}

print_data() {
    printf '{"out":{"vol":%s,"mute":%s,"name":"%s","id":%s,"icon":"%s"},"in":{"vol":%s,"mute":%s,"name":"%s","id":%s,"icon":"%s"}}\n'\
        $OUTVOL $OUTMUTE "$DEFAULT_SINK_DESC" "$DEFAULT_SINK" "$DEFAULT_SINK_ICON" $INVOL $INMUTE "$DEFAULT_SOURCE_DESC" "$DEFAULT_SOURCE" "$DEFAULT_SOURCE_ICON"
}


update_names
update_in
update_out
print_data
pactl subscribe | while read -r _ ev _ what index; do
    # volume change on output
    if [[ "$ev" == "'change'" && "$what" == "sink" && "$index" == "#$DEFAULT_SINK" ]]; then
        update_out
	print_data
    # volume change on input
    elif [[ "$ev" == "'change'" && "$what" == "source" && "$index" == "#$DEFAULT_SOURCE" ]]; then
        update_in
	print_data
    # can be whatever
    elif [[ "$ev" == "'change'" && "$what" == "server" ]]; then
        update_names
        update_in
        update_out
        print_data
    fi
done
