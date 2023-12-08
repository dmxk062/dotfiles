#!/usr/bin/env bash

POWER="󰐥"
REBOOT="󰑐"
SUSPEND="󰤄"
LOCK="󰌾"
LOGOUT="󰍃"

PROMPT="\0prompt\x1f"
META="\0meta\x1f"
DATA="\0data\x1f"

YES="󰄬    Yes"
NO="󰅖    No"

ask_confirm(){
    echo "Yes
No"|rofi -dmenu \
        -config "$XDG_CONFIG_HOME/rofi/applets/confirm.rasi"\
         -theme "$XDG_CONFIG_HOME/rofi/applets/power/theme.rasi"\
         -p "$1"|grep -q "Yes"
}
if [[ $ROFI_RETV -eq 0 ]]
then
    uptime="`uptime -p | sed -e 's/up //g'`"
    host=`< /etc/hostname`
    echo -en "${PROMPT}${uptime} ${USER}@${host}
${LOCK}${META}lock
${SUSPEND}${META}suspend sleep
${LOGOUT}${META}logout exit
${REBOOT}${META}reboot restart
${POWER}${META}power off
"
else
    case $1 in
        "$LOCK")
            echo -en "${PROMPT}Lock the Device?
${DATA}lock
$YES
$NO
"
            ;;
        "$SUSPEND")
            echo -en "${PROMPT}Suspend the Device?
${DATA}suspend
$YES
$NO
"
            ;;
        "$LOGOUT")
            echo -en "${PROMPT}Exit the Session?
${DATA}logout
$YES
$NO
"
            ;;
        "$REBOOT")
            echo -en "${PROMPT}Reboot the Device?
${DATA}reboot
$YES
$NO
"
            ;;
        "$POWER")
            echo -en "${PROMPT}Perform Device Shutdown?
${DATA}off
$YES
$NO
"
            ;;
        "$YES")
            case $ROFI_DATA in
                lock)
                    swaylock
                    ;;
                suspend)
                    swaylock
                    sleep 1
                    systemctl suspend
                    ;;
                logout)
                    hyprctl dispatch exit 1
                    ;;
                reboot)
                    systemctl reboot
                    ;;
                off)
                    systemctl poweroff
                    ;;
            esac
    esac

fi
