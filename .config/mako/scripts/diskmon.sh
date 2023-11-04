#!/usr/bin/env bash
# A script that triggers on inserted media



#read the output of udevadm into a buffer and read the event and path to the device /sys/... from it
stdbuf -oL -- udevadm monitor --udev -s block | while read -r -- _ _ event devpath _; do
        if [ "$event" = "add" ]; then
            if ! [[ "$devpath" =~ .*[0-9]$ ]]; then
                if [[ $(notify-send "Inserted Block Device" -i "/usr/share/icons/Tela/scalable/devices/media-flash-memory-stick.svg" --action=open="Open Disk Manager") == "open" ]]
                then
                    $HOME/.local/bin/eww_settings.sh storage & disown
                fi
            fi
        elif [[ "$event" == "remove" ]]; then #notifies on disk removal, opposite of check above
            if ! [[ "$devpath" =~ .*[0-9]$ ]]; then
            notify-send "Removed Block Device" -i "/usr/share/icons/Tela/scalable/devices/media-flash-memory-stick.svg"
            fi
        fi
        # update my settings menu's disk section
        $XDG_CONFIG_HOME/eww/settings/bin/disks.sh upd
done
echo "Error: stdbuf crashed for some reason"
