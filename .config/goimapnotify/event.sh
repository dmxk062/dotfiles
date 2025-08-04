#!/usr/bin/env bash

# only show messages received in the last 5 minutes
RECENT_MESSAGE=300

mbsync "$1"
sleep 1
notmuch new
sleep 1
[ "$2" != "new" ] && exit
notmuch search --sort=newest-first --limit=1 --format=json '*' |
	jq -r '.[0]|.timestamp,.authors,.subject,.date_relative' | {
	curtime=$(date +%s)
	read timestamp -r
	if [ $((curtime - timestamp)) -gt $RECENT_MESSAGE ]; then
		exit
	fi
	IFS= read author -r
	IFS= read subject -r
	IFS= read relative -r

	notify-send -i email "Mail from $author" "($relative) $subject"
}
