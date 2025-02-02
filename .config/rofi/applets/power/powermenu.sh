#!/usr/bin/env bash

POWEROFF="󰐥"
REBOOT="󰑐"
SUSPEND="󰤄"
LOCK="󰌾"
LOGOUT="󰍃"

PROMPT="\0prompt\x1f"
META="\0meta\x1f"
DATA="\0data\x1f"

YES="󰄬    Yes"
NO="󰅖    No"

# initial run
if [[ $ROFI_RETV -eq 0 ]]; then
    read uptime _ < /proc/uptime
    uptimestr="$(date -d "@$((${uptime%%.*} - 3600))" +"%H:%M")"
    echo -en "${PROMPT}up for ${uptimestr}
${LOCK}${META}lock
${SUSPEND}${META}suspend sleep
${LOGOUT}${META}logout exit
${REBOOT}${META}reboot restart
${POWEROFF}${META}power off shutdown
"
    exit
fi

declare -A questions=(
    ["$LOCK"]="Lock the Session?"
    ["$SUSPEND"]="Suspend the System?"
    ["$LOGOUT"]="Exit the Session?"
    ["$REBOOT"]="Reboot the System?"
    ["$POWEROFF"]="Halt System?"
)

if [[ "$1" == "$NO" ]]; then
    exit
elif [[ "$1" == "$YES" ]]; then
    case $ROFI_DATA in
    "$LOCK")
        swaylock
        ;;
    "$SUSPEND")
        swaylock
        sleep 1
        systemctl suspend
        ;;
    "$LOGOUT")
        if [[ -n "$SWAYSOCK" ]]; then
            swaymsg exit
        fi
        ;;
    "$REBOOT")
        systemctl reboot
        ;;
    "$POWEROFF")
        systemctl poweroff
        ;;
    esac
    exit
fi

# ask the question
echo -en "${PROMPT}${questions[$1]}
$DATA$1
$YES
$NO"
