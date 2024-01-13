#!/usr/bin/env bash

if [[ "$1" == "--initial" ]]; then
    nwg-drawer -c 8 \
               -fm nautilus \
               -ovl \
               -nofs \
               -term "kitty" \
               -is 64 \
               -nocats -r & disown 
    exit
fi


nwg-drawer -c 8 \
           -fm nautilus \
           -ovl \
           -nofs \
           -term "kitty" \
           -is 64 \
           -nocats & disown 
