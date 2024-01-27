#!/usr/bin/env bash
# A script that triggers on inserted media

USB_SYMBOLIC="drive-removable-media-usb-symbolic"
USB_SCALED="media-flash-memory-stick"
HDD_SYMBOLIC="drive-harddisk-system-symbolic"
HDD_SCALED="drive-harddisk-usb"


notify_on_insert(){
    answer="$(notify-send -a "eww" -i "$2" \
        --action="open_e"="Open Disk Manager" \
        --action="open_g"="Open in Disks" \
        "Inserted ${1}"
        )"

    case $answer in
        open_e)
            $HOME/.local/bin/eww_settings.sh storage & disown
            eww -c "$XDG_CONFIG_HOME/eww/settings" update disk_parts="$3"
            ;;
        open_g)
            gnome-disks --block-device="$3"& disown;;
    esac

}


#read the output of udevadm into a buffer and read the event and path to the device /sys/... from it
stdbuf -oL -- udevadm monitor --udev -s block | while read -r -- _ _ event devpath _; do
        if [ "$event" = "add" ]; then
            if ! [[ "$devpath" =~ .*[0-9]$ ]]; then
                fullpath="/sys/${devpath}"
                shortname="$(basename "$fullpath")"
                devfs_name="/dev/${shortname}"
                name="$( < "${fullpath}/device/model")"
                notify_on_insert "$name" "$USB_SYMBOLIC" "${devfs_name}" 
            fi
        elif [[ "$event" == "remove" ]]; then #notifies on disk removal, opposite of check above
            if ! [[ "$devpath" =~ .*[0-9]$ ]]; then
            notify-send "Removed Block Device" -i "drive-removable-media-usb-symbolic"
            fi
        fi
        # update my settings menu's disk section
        $XDG_CONFIG_HOME/eww/settings/bin/disks.sh upd
done
echo "Error: stdbuf crashed for some reason"
