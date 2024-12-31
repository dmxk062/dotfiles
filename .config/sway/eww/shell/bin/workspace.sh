#!/usr/bin/env bash

upd() {
    swaymsg -t get_workspaces | jq 'sort_by(.num, .name)' -rjc
    echo
}

upd
swaymsg -t subscribe '["workspace"]' -m | {
    while read -r m; do
        upd
    done
}
