#!/bin/bash

noconfirm=$2
function prompt(){
    question=$1
    action=$2
    if [[ $noconfirm == "-nc" ]]
    then
        bash -c "$action"
    else
        if zenity --question --text="$question"
        then
            bash -c "$action"
        else
            exit
        fi
    fi
}
case $1 in
    off)
        prompt "Shutdown System?" "systemctl poweroff"
        ;;
    reboot)
        prompt "Reboot System?" "systemctl reboot"
        ;;
    lock)
        prompt "Lock Screen?" "gtklock -dS"
        ;;
    suspend)
        prompt "Suspend System?" "gtklock -dS&& sleep 1 &&systemctl suspend"
        ;;
    logout)  
        prompt "Logout to TTY?" "hyprctl dispatch exit 1"
        ;;
    uefi)
        prompt "Reboot into Firmware Setup?" "systemctl reboot --firmware-setup"
esac
