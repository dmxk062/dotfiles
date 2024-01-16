#!/usr/bin/env bash

cd || exit
title="$1"
data="$2"
name="$3"

savepath="$(zenity --file-selection \
    --title="$title" \
    --save --filename="$name")"

if [[ "$savepath" == "" ]]; then
    exit
else
    echo "$data" > "$savepath" 
fi
