#!/bin/bash

LOCKFILE="/tmp/eww/state/no_popups"
eww="eww -c $HOME/.config/eww/shell"

update(){
    eww -c $XDG_CONFIG_HOME/eww/settings update "$@"&
    eww -c $XDG_CONFIG_HOME/eww/shell/ update "$@"&
}

if [[ "$2" == "audio" ]]; then
        case $3 in
            raise)
                wpctl set-volume @${5}@ ${4}%+ -l 1&;;
            lower)
                wpctl set-volume @${5}@ ${4}%- -l 1&;;
            mute)
                wpctl set-mute @${4}@ toggle
        esac
        (sleep .1
        update audio_state="$(printf '{"sink":{"vol":%s,"mute":%s},"source":{"vol":%s,"mute":%s}}' "$(pamixer --get-volume)" "$(pamixer --get-mute)" "$(pamixer --get-volume --default-source)" "$(pamixer --get-mute --default-source)")")&
else
    $eww update brightness=$(light -G)
fi
[ -f "$LOCKFILE" ]&&exit

get_screen(){
    hyprctl monitors -j|jq '.[]|select(.focused)|.id'
}




oldid=$(pgrep "open_popup" |head -n 1)

if [[ $oldid == $BASHPID ]]; then
case $1 in 
    in)
        $eww open in_popup --screen $(get_screen)
        sleep 2
        $eww close in_popup
        ;;
    out)
        $eww open out_popup --screen $(get_screen)
        sleep 2
        $eww close out_popup
        ;;
    light)
        $eww open bright_popup --screen $(get_screen)
        sleep 2
        $eww close bright_popup
        ;;
esac
fi
