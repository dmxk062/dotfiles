#!/usr/bin/env bash

DEFAULT_INNER=4
DEFAULT_OUTER=8

current_ws="$(swaymsg -t get_workspaces | jq '.[]|select(.focused).id' -r)"
is_gapless="$(swaymsg -t get_tree | jq --argjson cur "$current_ws" \
    '.nodes.[]|select(.name != "__i3")|{
        screen: .rect,
        ws: (.nodes.[]|select(.id == $cur).rect)
    }|if .screen.width == .ws.width then 1 else 0 end')"


if ((is_gapless)); then
    outer=$DEFAULT_OUTER
    inner=$DEFAULT_INNER
else 
    outer=0
    inner=0
fi
swaymsg "gaps outer current set $outer; gaps inner current set $inner"
