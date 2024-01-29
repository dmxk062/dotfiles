#!/usr/bin/env bash
LOGFILE="/tmp/eww/state/prompt/history"
INDEXFILE="/tmp/eww/state/prompt/index"
update(){
    eww -c $XDG_CONFIG_HOME/eww/shell update $@
}
update_single(){
    eww -c $XDG_CONFIG_HOME/eww/shell update "$1"="$2"
}
format_hist(){
    printf '{"pos":%s,"len":%s,"pos_f":"%s"}\n' $1 $2 $3
}
index="$(< $INDEXFILE)"
len="$(wc -l < "$LOGFILE")"

case $1 in
    up)
        ((index--))
        index=$((index <= 1 ? 1 : index ))
        cmd="$(sed -n "${index}p" "$LOGFILE")"
        update_single prompt_current "$cmd"
        update_single prompt_hist "$(format_hist $index $len $index)"
        ;;
    down)
        ((index++))
        if ((index >= len));
        then
            cmd=""
            index=$len
            index_f="new"
        else
            cmd="$(sed -n "${index}p" "$LOGFILE")"
            index_f="$index"
        fi
        update_single prompt_current "$cmd"
        update_single prompt_hist "$(format_hist $index $len $index_f)"
        ;;
esac
echo $index > $INDEXFILE
