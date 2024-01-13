#!/usr/bin/env bash

cd || exit
title="$1"
origin="$2"
name="$3"

savepath="$(zenity --file-selection \
    --title="$title" \
    --save \
    --filename="$name" \
    --confirm-overwrite)"

if [[ "$savepath" == "" ]]; then
    exit
else
    cp "$origin" "$savepath"
fi
