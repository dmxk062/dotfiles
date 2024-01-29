#!/usr/bin/env bash
LOGFILE="/tmp/eww/state/prompt/history"
INDEXFILE="/tmp/eww/state/prompt/index"
MAX_COUNT=512
MAX_DEPTH=6
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

search_files(){
    cd "$2"||exit
    echo "["
    l="$(fd "$1" -ad $MAX_DEPTH --type file --threads=16 -x echo '{{ "path":"{}", "name":"{/}", "parent":"{//}" }},'|head -n $MAX_COUNT)"
    echo "${l%?}"
    echo "]"

}
search_dirs(){
    cd "$2"||exit
    echo "["
    l="$(fd "$1" -ad $MAX_DEPTH --type directory --threads=16 -x echo '{{ "path":"{}", "name":"{/}" }},' |head -n $MAX_COUNT)"
    echo "${l%?}"
    echo "]"

}
prefind_dir(){
    fd -aL --max-results 2 --type directory -d 3 "$1"|head -n 1
}

update prompt_current='' prompt_is_loading='true' prompt_result_type='regular'

case $MODE in
    run)
        COMMAND="${FULL_COMMAND/">"/}"
        command_thread "$COMMAND" & disown
        close
        ;;
    launch)
        COMMAND="${FULL_COMMAND/":"/}"
        gtk-launch "$COMMAND" & disown
        close
        ;;
    math)
        expr="${FULL_COMMAND/"%"/}"
        result="$(\qalc $expr|sed -e ':a;N;$!ba;s/\n/\\n/g' -e 's/"/\\"/g')"
        stripped="${result/ /}"
        if grep -q "error" <<< "$stripped"; then
            error=true
            result_value=""
        else
            error=false
            IFS='=' read -ra fields <<< "$stripped"
            result_value="${fields[-1]}"
        fi
        old="$(eww -c $XDG_CONFIG_HOME/eww/shell get "prompt_math_results")"
        new="$(printf '{"input":"%s", "output":"%s", "result":"%s", "error":%s}' "$expr" "$result" "$result_value" "$error")"
        updated="$(echo "$old"|jq --argjson new "$new" '. |= [$new] + .')"
        eww -c $XDG_CONFIG_HOME/eww//shell update prompt_mode='default' prompt_error='false' \
            prompt_show_help='false'  prompt_has_result='true' prompt_result_type='math'
        update_single prompt_math_results "$updated"
        ;;
    search_dir)
        cd || exit
        IFS='\' read -r _ pre actual <<< "${FULL_COMMAND}"
        if [[ "$actual" != "" ]]; then
            predir="$(prefind_dir "$pre")"
            searchterm="$actual"
        else
            predir="$HOME"
            searchterm="$pre"
        fi
        matches="$(search_dirs "$searchterm" "$predir")"
        eww -c $XDG_CONFIG_HOME/eww//shell update prompt_mode='default' prompt_error='false' \
            prompt_show_help='false'  prompt_has_result='true' prompt_result_type='search' prompt_search_item="dir" 
        update_single prompt_search_result "$matches"
        ;;
    search_file)
        cd || exit
        IFS='/' read -r _ pre actual <<< "${FULL_COMMAND}"
        if [[ "$actual" != "" ]]; then
            predir="$(prefind_dir "$pre")"
            searchterm="$actual"
        else
            predir="$HOME"
            searchterm="$pre"
        fi
        matches="$(search_files "$searchterm" "$predir")"
        eww -c $XDG_CONFIG_HOME/eww//shell update prompt_mode='default' prompt_error='false' \
            prompt_show_help='false' prompt_has_result='true' prompt_result_type='search' prompt_search_item="file"
        update_single prompt_search_result "$matches"
        ;;
    default)
        case $FULL_COMMAND in
            clear|c|:c)
                rm "$LOGFILE"
                update prompt_mode='default' prompt_error='false' prompt_show_help='false' prompt_has_result='false' prompt_search_result='[]' prompt_math_results='[]'
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
echo $((len+1)) > "$INDEXFILE"
update prompt_hist="{\"len\":$len,\"pos\":$len,\"pos_f\":\"new\"}" prompt_is_loading='false'
