#!/bin/bash -e

ROFI="rofi -dmenu -i -p"
function display_menu(){
   echo "$1"|$ROFI||exit
}
function check_json_value(){
    query="$2"
    echo "$1"|jq -r "$query"
}
function volume_slider(){
    stdbuf -oL zenity --scale --text="$4" --value="$1" --step=5 --print-partial --extra-button="Toggle Mute"|while read -r value
    do
        if [[ "$value" == "Toggle Mute" ]]
        then
            pactl set-${3}-mute $2 toggle
        else
            pactl set-${3}-volume $2 $value%
        fi
    done
}
opts_main="Window
Screenshot
Audio
Power
Exit"
main_menu(){
    chosen=$(display_menu "$opts_main")
    case $chosen in
        Window)
            win_menu;;
        Audio)
            audio_menu;;
        Screenshot)
            sc_menu;;
        Power)
            power_menu;;
        Admin)
            admin_menu;;
        Exit)
            exit;;
    esac
}

sc_menu(){
    selfile="Selection > File"
    selclip="Selection > Clipboard"
    screenfile="Screen > File"
    screenclip="Screen > Clipboard"
    opts_sc="$selfile
$screenfile
$selclip
$screenclip
Back
Exit"
    chosen=$(display_menu "$opts_sc")
    echo "$chosen"
    case $chosen in
        Back)
            main_menu;;
        Exit)
            exit;;
        "$selfile")
            $HOME/.local/bin/screenshot.sh selection file;;
        "$selclip")
            $HOME/.local/bin/screenshot.sh selection clip;;
        "$screenfile")
            $HOME/.local/bin/screenshot.sh monitor file;;
        "$screenclip")
            $HOME/.local/bin/screenshot.sh monitor clip;;
    esac
    main_menu

}

win_menu(){
    win=$(hyprctl activewindow -j)
    if [[ $win == "{}" ]]
    then
        notify-send "No Active Window"
        main_menu
    else
        if [[ $(check_json_value "$win" '.floating' ) == "true" ]]
        then
            float="Unfloat"
            if [[ $(check_json_value "$win" '.pinned') == "true" ]]
            then
                pin="Unpin"
            else
                pin="Pin"
            fi
        else
            float="Float"
            pin="Can't pin"
        fi
        fullscreenMode=$(check_json_value "$win" '.fullscreenMode')
        if [[ $(check_json_value "$win" '.fullscreen') == "true" ]]
        then
            if [[ $fullscreenMode == "0" ]]
            then
                fullscreen="Unfullscreen"
                maximize="Maximize"
            else
                fullscreen="Fullscreen"
                maximize="Unmaximize"
            fi
        else
            fullscreen="Fullscreen"
            maximize="Maximize"
        fi
        opts_win="$float
$pin
$fullscreen
$maximize
Close
Back
Exit"
        chosen=$(display_menu "$opts_win")
        case $chosen in
            Close)
                hyprctl dispatch killactive
                main_menu;;
            Back)
                main_menu;;
            Exit)
                exit;;
            "$fullscreen")
                hyprctl dispatch fullscreen 0
                win_menu;;
            "$maximize")
                hyprctl dispatch fullscreen 1
                win_menu;;
            "$float")
                hyprctl dispatch togglefloating
                win_menu;;
            "$pin")
                hyprctl dispatch pin
                win_menu;;
        esac
    fi
}
audio_menu(){
    volume=$(pamixer --get-volume)
    input_volume=$(pamixer --get-volume --default-source)
    current_sink=$(pactl --format=json list sinks| jq -r --arg current "$(pactl get-default-sink)" '.[]|select(.name==$current)|.description')
    current_source=$(pactl --format=json list sources| jq -r --arg current "$(pactl get-default-source)" '.[]|select(.name==$current)|.description')
    sink_item="Out: $current_sink"
    source_item="In: $current_source"
    volume_item="Out: ${volume}%"
    input_volume_item="In: ${input_volume}%"
    opts_audio="$volume_item
$input_volume_item
$sink_item
$source_item
Mixer
Back
Exit"
    chosen=$(display_menu "$opts_audio")
    case $chosen in 
        Back)
            main_menu;;
        Exit)
            exit;;
        "$volume_item")
            volume_slider $volume '@DEFAULT_SINK@' 'sink' "Output Volume"
            ~/.config/eww/settings/bin/aux.sh get-all out
            audio_menu;;
        "$input_volume_item")
            volume_slider $input_volume '@DEFAULT_SOURCE@' 'source' "Input Volume"
            ~/.config/eww/settings/bin/aux.sh get-all in
            audio_menu;;
        "$sink_item")
            sinks=$(pactl --format=json list sinks|jq -r '.[].description')
            chosen=$(display_menu "$sinks")
            sinkid=$(pactl --format=json list sinks| jq -r --arg sel "$chosen" '.[]|select(.description == $sel)|.name')
            pactl set-default-sink "$sinkid"
            ~/.config/eww/settings/bin/sinks_sources.sh upd sink
            ~/.config/eww/settings/bin/aux.sh get-all out
            audio_menu;;
        "$source_item")
            sources=$(pactl --format=json list sources|jq -r '.[].description')
            chosen=$(display_menu "$sources")
            sourceid=$(pactl --format=json list sources| jq -r --arg sel "$chosen" '.[]|select(.description == $sel)|.name')
            pactl set-default-source "$sourceid"
            ~/.config/eww/settings/bin/sinks_sources.sh upd source
            ~/.config/eww/settings/bin/aux.sh get-all in
            audio_menu;;
        Mixer)
            sinkIds=$(pactl --format=json list sink-inputs| jq -r '.[]|.index')
            declare -A sinks
            for i in ${sinkIds// / }
            do
                name=$(pactl list sink-inputs|grep "$i" -A30|grep media.name|awk -F = '{print $2}')
                sinks+=( [$name]=$i)
            done
            items=$(for item in "${!sinks[@]}"
            do
                id=${sinks[$item]}
                item=$(echo $item|sed 's/"//g'|sed 's/\\//g')
                echo "$item:::$id"
            done
            )
            items+="
Back"
            items+="
Exit"
            selected=$(display_menu "$items")
            if [[ $selected == "Back" ]]
            then
                audio_menu
            elif [[ $selected == "Exit" ]]
            then
                exit
            else
                sel_name=$(echo  $selected|awk -F ":::" '{print $1}')
                sel_id=$(echo  $selected|awk -F ":::" '{print $2}')
                volume=$(pactl --format=json list sink-inputs |jq -r --argjson id $sel_id '.[]|select(.index==$id)|.volume|."front-left"|.value_percent')
                volume=${volume::-1} #get rid of pesky % sign
                volume_slider $volume "$sel_id" 'sink-input' "$sel_name"
                audio_menu
            fi;;




    esac
}

power_menu(){
    off="   Power Off"
    reboot="   Reboot"
    lock="   Lock Session"
    suspend="󰤄   Suspend"
    logout="󰍃   Logout to TTY"
    uefi="󰘚   Reboot into Firmware"
    opts_power="$lock
$logout
$suspend
$reboot
$off
$uefi
Back
Exit"
    chosen=$(display_menu "$opts_power")
    case $chosen in
        "$off")
            ~/.config/eww/top-bar/bin/shutdown.sh off;;
        "$reboot")
            ~/.config/eww/top-bar/bin/shutdown.sh reboot;;
        "$lock")
            ~/.config/eww/top-bar/bin/shutdown.sh lock -nc;;
        "$suspend")
            ~/.config/eww/top-bar/bin/shutdown.sh suspend -nc;;
        "$logout")
            ~/.config/eww/top-bar/bin/shutdown.sh logout;;
        "$uefi")
            ~/.config/eww/top-bar/bin/shutdown.sh uefi;;
        Back)
            main_menu;;
        Exit)
            exit;;
    esac
}



case $1 in
    power)
        power_menu;;
    win)
        win_menu;;
    audio)
        audio_menu;;
    screen)
        sc_menu;;
    *)
        main_menu;;
esac
