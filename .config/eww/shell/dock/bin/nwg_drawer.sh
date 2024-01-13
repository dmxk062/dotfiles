#!/usr/bin/env bash

nwg-drawer -c 8 \
           -fm nautilus \
           -ovl \
           -nofs \
           -term "kitty" \
           -is 64 \
           -nocats & disown 
