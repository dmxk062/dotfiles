#!/bin/bash

eww="eww -c $HOME/.config/eww/shell"

if $eww active-windows | grep "session_popup"; then
    sleep 0.2
    $eww close session_popup
else
    $eww open session_popup
    $eww update user="$USER"
    $eww update boottime="$(awk '/btime/ {print $2}' /proc/stat)"
    $eww update hostname="$(< /etc/hostname)"
fi
