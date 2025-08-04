#!/usr/bin/env bash

# only show messages received in the last 5 minutes
RECENT_MESSAGE=300

mbsync "$1"
[ "$2" != "new" ] && exit
himalaya envelope list -o json order by date desc |
    jq -r '.[0]| (.date|strptime("%Y-%m-%d %H:%M%z")|mktime) as $time | $time, (.from.name // .from.addr), .subject, ($time | strftime("%H:%M"))' | {
    curtime=$(date +%s)
    read -r timestamp
    read -r author
    read -r subject
    read -r date
    if [ $((curtime - timestamp)) -gt $RECENT_MESSAGE ]; then
        exit
    fi

    notify-send -i email "$author" "($date) $subject"
}
