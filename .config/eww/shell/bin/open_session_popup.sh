#!/bin/bash

eww="eww -c $HOME/.config/eww/shell"

if ! $eww close session_popup
then
    $eww open session_popup
    $eww update user="$USER"
    $eww update boottime="$(awk '/btime/ {print $2}' /proc/stat)"
    $eww update hostname="$(< /etc/hostname)"
fi
