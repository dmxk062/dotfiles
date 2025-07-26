#!/usr/bin/env bash

IFS=$'\t' read -ra marks < <(swaymsg -t get_marks | jq -jr '.[]|"\(.)\t"')

mark="$(wayinput -t "mark" "$@" -c "${marks[@]}")"
if [ -n "$mark" ]; then
    swaymsg "[con_mark=^$mark]" focus
fi
