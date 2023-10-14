#!/usr/bin/env bash

eww="eww -c $HOME/.config/eww/top-bar"

if ! $eww close session_popup
then
    $eww open session_popup
    $eww update user="$USER"
    $eww update boottime="$(awk '/btime/ {print $2}' /proc/stat)"
    $eww update hostname="$(< /etc/hostname)"
fi
