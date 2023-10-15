#!/bin/sh

update(){
    eww -c $XDG_CONFIG_HOME/eww/settings update "$@"& # send whatever to eww
    eww -c $XDG_CONFIG_HOME/eww/top-bar/ update "$@"& # send whatever to eww
    eww -c $XDG_CONFIG_HOME/eww/popups/ update "$@"& # send whatever to eww
}

update audio_state="$(printf '{"sink":{"vol":%s,"mute":%s},"source":{"vol":%s,"mute":%s}}' "$(pamixer --get-volume)" "$(pamixer --get-mute)"\
    "$(pamixer --get-volume --default-source)" "$(pamixer --get-mute --default-source)")"
