#!/usr/bin/env bash

media_names="$(pactl list sink-inputs | grep 'media.name' | cut -d"=" -f 2 | sed -e 's/^\s*"//' -e 's/"\s*$//')"


pactl --format=json list sink-inputs | jq --arg _names "$media_names" '. as $streams | $_names | split("\n") as $names |
    $streams | [foreach .[] as $stream (-1; . + 1;  {
    id: $stream.index,
    mute: $stream.mute,
    volume: ($stream.volume."front-left".value_percent[:-1] | tonumber),
    name: $names[.],
    app_name: $stream.properties."application.name",
    app: $stream.properties."application.process.binary",
    icon: ($stream.properties."application.icon_name" // $stream.properties."application.process.binary")
})]'
