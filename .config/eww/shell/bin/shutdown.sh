#!/bin/bash

noconfirm=$2
prompt(){
    question=$1
    action=$2
    if [[ $noconfirm = "-nc" ]]
    then
        sh -c "$action"
    else
        if ! zenity --question --text="$question" --title="Power Management"
        then
            exit
        fi
    fi
}
case $1 in
    off)
        prompt "Perform Shutdown?" 
        systemctl poweroff
        ;;
    reboot)
        prompt "Reboot System?" 
        systemctl reboot
        ;;
    lock)
        prompt "Lock Screen?" 
        swaylock
        ;;
    suspend)
        prompt "Suspend System?" 
        swaylock
        sleep 1
        systemctl suspend
        ;;
    logout)  
        prompt "Logout to TTY?" 
        hyprctl dispatch exit 1
        ;;
    uefi)
        prompt "Reboot into Firmware Setup?" 
        systemctl reboot --firmware-setup
        ;;
    hibernate)
        prompt "Hibernate to Disk?" 
        if ! systemctl hibernate; then
            notify-send "Failed to Hibernate" \
                -a eww \
                -i drive-harddisk-root \
                "Make sure you have enough physical swap"
        fi
        ;;
esac
