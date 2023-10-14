#!/usr/bin/env bash
# A script that triggers on inserted media



#converts a path given by udeavadm to a regular device file (dev/smth)
function pathtoname() {
    udevadm info -p /sys/"$1" | awk -v FS== '/DEVNAME/ {print $2}'
}


#converts a device file name to the label name
function pathtolabel(){
    udevadm info -p /sys/"$1" | awk -v FS== '/ID_FS_LABEL/ {print $2;exit}'
}



#converts the path given by udevadm to the filesystem 
function pathtofstype(){
    udevadm info -p /sys/"$1" | awk -v FS== '/ID_FS_TYPE/ {print $2}'
}




#handles LUKS encrypted devices
function handleluks(){
    passwd=$(zenity --entry --hide-text --text "Enter Password for $devname" --title "zenity_passwd") #gets the password using zenity
    if udisksctl unlock -b "$devname" --key-file <(echo -n "$passwd"); then #tries to decrypt
        notify-send "Successfully decrypted $devname" -i "/usr/share/icons/Tela/24/panel/cryptfolder-open-light.svg" -c "udiskmon_success" #if successful, notify the user -> the disk will show up later(at the end of all the partitions of the disk)
    else
        notify-send "Failed to Unlock $devname" -i "/usr/share/icons/Tela/24/panel/cryptfolder-closed-light.svg" -c "udiskmon_fail" #same if it fails
    fi
}



#asks the user whether to mount an inserted volume
function askForAction() {
    answer=$(notify-send "Inserted $label ($(basename "$devname"))" "Mount filesystem of type ${fstype}?" -i "/usr/share/icons/Tela-dark/symbolic/devices/drive-removable-media-usb-symbolic.svg" --action="no"="No" --action="yes"="Yes" -c "udiskmon") #gets an answer using notify-sends menu system, the udiksmon category is recognised by my mako config
    case $answer in
        yes) #decrypts before trying to mount
            if [[ "$fstype" == "crypto_LUKS" ]]; then
                handleluks
                return
            fi
            #otherwise mount and notifies the user if it succeeds/fails
            if result=$(udisksctl mount -b "$devname"); then
                notify-send "Successfully mounted $label" "$result" -i "/usr/share/icons/Tela-dark/16/actions/kr_mountman.svg" -c "udiskmon_success"
            else
                notify-send "Failed to mount $label" "$result" -i "/usr/share/icons/Tela-dark/16/actions/error.svg" -c "udiskmon_fail"
            fi
            ;;
        no)
            return
            ;;
    esac

}





#read the output of udevadm into a buffer and read the event and path to the device /sys/... from it
stdbuf -oL -- udevadm monitor --udev -s block | while read -r -- _ _ event devpath _; do
        if [ "$event" = "add" ]; then
            devname=$(pathtoname "$devpath") #determines /dev/... name
            if [[ "$devname" =~ .*[0-9]$ ]]; then #checks if we have a partition or a whole disk
                label=$(pathtolabel "$devpath")
                if [[ "$label" == "" ]]; then #if the partition doesnt have a label, assign one to it
                    label="No Label"
                fi
                fstype=$(pathtofstype "$devpath") #get the type of filesystem
                askForAction
            elif  ! ls ${devname}1 && ! ls ${devname}2 && ! ls ${devname}3;then
                label=$(pathtolabel "$devpath")
                if [[ "$label" == "" ]]; then #if the partition doesnt have a label, assign one to it
                    label="No Label"
                fstype=$(pathtofstype "$devpath") #get the type of filesystem
                askForAction
                fi
            fi

        elif [[ "$event" == "remove" ]]; then #notifies on disk removal, opposite of check above
            if ! [[ "$devpath" =~ .*[0-9]$ ]]; then
            notify-send "Removed Block Device" -i "/usr/share/icons/Tela-dark/symbolic/devices/drive-removable-media-usb-symbolic.svg" -c "udiskmon_fail"
            fi
        fi
        # update my settings menu's disk section
        $XDG_CONFIG_HOMR/eww/settings/bin/disks.sh upd
done
