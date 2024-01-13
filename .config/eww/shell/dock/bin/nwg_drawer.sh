#!/usr/bin/env bash

killall nwg-drawer
sleep 0.1
nwg-drawer -c 8 \
           -fm nautilus \
           -ovl \
           -term "kitty" \
           -is 64 \
           -nofs \
           -nocats -r & disown 
