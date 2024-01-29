#!/usr/bin/env bash
LOGFILE="/tmp/eww/state/prompt/history"
INDEXFILE="/tmp/eww/state/prompt/index"
update(){
    eww -c $XDG_CONFIG_HOME/eww/shell update $@
}
update_single(){
    eww -c $XDG_CONFIG_HOME/eww/shell update "$1"="$2"
}
error(){
    eww -c $XDG_CONFIG_HOME/eww/shell update prompt_error="true" prompt_error_msg="$1"
}

close(){
    update prompt_mode='default' prompt_current='' prompt_error='false' prompt_show_help='false'
    eww -c $XDG_CONFIG_HOME/eww/shell close prompt_window
    hyprctl dispatch submap reset
}
command_thread(){
    stderr="$({ eval "$*" > /dev/null; } 2>&1)"
    exit_code=$?
    stderr="$(echo "$stderr"| sed -e 's/.*line [0-9]*://g' -e 's/^ *//')"
    if ((exit_code == 0)); then
        notify-send "Command finished $exit_code" "$@" -a "eww" -i dialog-information
    else
        notify-send "Command failed: $exit_code" "$@
$stderr" -a "eww" -i system-error
    fi
}

return_val(){
    result="$(printf '{"title":"%s","body":"%s","icon":"%s"}' "$1" "$2" "$3")" 
    eww -c $XDG_CONFIG_HOME/eww//shell update prompt_mode='default' prompt_error='false' prompt_show_help='false' prompt_has_result='true' \
        prompt_result="$result"
        
}
MODE="$1"
FULL_COMMAND="$2"
if [[ "$FULL_COMMAND" == "" ]]; then
    exit
fi

update prompt_current='' prompt_is_loading='true'

case $MODE in
    run)
        COMMAND="${FULL_COMMAND/">"/}"
        command_thread "$COMMAND" & disown
        close
        ;;
    default)
        case $FULL_COMMAND in
            clear|c|:c)
                rm "$LOGFILE"
                update prompt_mode='default' prompt_error='false' prompt_show_help='false' prompt_has_result='false'
                ;;
            help|h|:h)
                update prompt_mode='default' prompt_error='false' prompt_show_help='true' prompt_has_result='false'
                ;;
            exit|x|quit|q|:q)
                close
                ;;
            ws*)
                name="${FULL_COMMAND/"ws"/}"
                name="${name/\ /}"
                if ! [[ $name =~ ^[0-9]*$ ]]; then
                    name="name:$name"
                fi
                close
                ;;
            date)
                time="$(date "+%H:%M:%S on %Y/%m/%d")"
                return_val "Current time & date" "$time" "clock"
                ;;
            updates)
                updates="$(checkupdates --nocolor)"
                updateCount="$(wc -l <<< "$updates")"
                kline="$(echo "$updates"|grep '^linux\s.*$')"
                if [[ $kline != "" ]]; then
                    read -r _ oldver newver <<< "$kline"
                    newver=${newver:3}
                    body="Update contains kernel update:\nfrom $oldver to $newver"
                else
                    body="Only userspace components will be updated"
                fi
                return_val "${updateCount} Updates available" "$body" "update"
                ;;
            *)
                update prompt_mode='default' prompt_error='true' prompt_show_help='false' prompt_has_result='false'
                error "Unknown command: '${FULL_COMMAND}'. Use 'help' to see all commands"
            ;;
    esac

esac
echo "$FULL_COMMAND" >> "$LOGFILE"
len=$(wc -l < "$LOGFILE" )
echo $len > "$INDEXFILE"
update prompt_hist="{\"len\":$len,\"pos\":$len,\"pos_f\":\"new\"}" prompt_is_loading='false'
