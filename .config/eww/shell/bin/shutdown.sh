#!/bin/sh

noconfirm=$2
prompt(){
    question=$1
    action=$2
    if [ $noconfirm = "-nc" ]
    then
        sh -c "$action"
    else
        if zenity --question --text="$question"
        then
            sh -c "$action"
        else
            exit
        fi
    fi
}
case $1 in
    off)
        prompt "Perform Shutdown?" "systemctl poweroff"
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
        ;;
    hibernate)
        prompt "Suspend to Disk?" "systemctl hibernate"
        ;;
esac
