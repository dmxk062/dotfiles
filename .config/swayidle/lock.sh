#!/usr/bin/env bash

if pgrep gtklock; then
    gtklock -d
else
    cd
    gtklock -d
    systemctl suspend
fi
