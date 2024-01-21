#!/usr/bin/env zsh
LOCKFILE="/tmp/eww/state/gaming/overlay"

EVENT_JS='2,'
EVENT_BTN='1,'

UP="13,"
DOWN="14,"
LEFT="15,"
RIGHT="16,"

B="0,"
A="1,"
X="2,"
Y="3,"

MINUS="8,"
PLUS="9,"
HOME="10,"

LEFT_HORIZONTAL="0,"
LEFT_VERTICAL="1,"

RIGHT_HORIZONTAL="2,"
RIGHT_VERTICAL="3,"

#left for  more precise movements
SPEED_DIVIDER_R=1000
SPEED_DIVIDER_L=3000

shell(){eww -c "$XDG_CONFIG_HOME/eww/shell" "$@"}

toggle_settings(){
    if ! eww -c "$XDG_CONFIG_HOME/eww/settings" close settings; then
        eww_settings.sh
    fi
}
toggle_perf_popup(){
    if ! shell close performance_popup; then
        shell open performance_popup
    fi
}

get_file(){
    echo /dev/input/js*
}

get_meta(){
    shortname="$(basename "$1")"
    shell update game_jsname="$(< /sys/class/input/${shortname}/device/name)"
}

function monitor(){

overlay_active=false
home_pressed=false


initial=true
jstest --event "$1"| while read -r _ _ type _ time _ id _ value; do
    if [[ $id == $HOME ]];
    then
        [[ $value == 1 ]]&&home_pressed=true||home_pressed=false
    fi
    if [[ "$type" == $EVENT_JS ]]&& $overlay_active; then
        case $id in
            $LEFT_VERTICAL)
                ydotool mousemove -y $((value/SPEED_DIVIDER_L)) -x 0& disown
                ;;
            $LEFT_HORIZONTAL)
                ydotool mousemove -x $((value/SPEED_DIVIDER_L)) -y 0& disown
                ;;
            $RIGHT_VERTICAL)
                ydotool mousemove -y $((value/SPEED_DIVIDER_R)) -x 0& disown
                ;;
            $RIGHT_HORIZONTAL)
                ydotool mousemove -x $((value/SPEED_DIVIDER_R)) -y 0& disown
                ;;
        esac
    elif [[ "$type" == $EVENT_BTN ]]; then
        case $id in 
            $A)
                if [[ $value == 0 ]] && $overlay_active; then
                    ydotool click 0x80& disown
                else
                    ydotool click 0x40& disown
                fi;;
            $B)
                if [[ $value == 0 ]] && $overlay_active; then
                    ydotool click 0x81& disown
                else
                    ydotool click 0x41& disown
                fi;;
            $MINUS)
                if [[ $value == 1 ]] && $overlay_active; then
                    toggle_settings
                fi;;
            $PLUS)
                if [[ $value == 1 ]]; then
                    if $home_pressed; then
                        $overlay_active&&overlay_active=false||overlay_active=true
                        continue
                    fi
                    if $overlay_active; then
                       toggle_perf_popup
                    fi
                fi
        esac
    fi
    initial=false
done
}



joypath="$(get_file)"
get_meta "$joypath"
monitor "$joypath"
