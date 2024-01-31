#!/bin/bash
eww="eww -c $HOME/.config/eww/settings"
#lsblk -J --output=LABEL,NAME,PATH,PARTUUID,UUID,TRAN,VENDOR,FSSIZE,FSUSE%,FSUSED,MODEL,VENDOR,MOUNTPOINTS,PARTTYPENAME,FSTYPE
icons_g='{
"sata":"drive-harddisk-ieee1394",
"nvme":"drive-harddisk-solidstate",
"usb":"media-flash-memory-stick",
"default":"drive-harddisk",
"mmc":"media-flash",
"mem":"media-memory"
}'
icons='{
"sata":"󰋊",
"nvme":"",
"usb":"󱇰",
"default":"󰋊",
"mmc":"󰟜",
"mem":"󱤓"
}'
function list(){
    lsblk -J --output=LABEL,NAME,PATH,PARTUUID,UUID,TRAN,VENDOR,FSSIZE,FSUSE%,FSUSED,MODEL,VENDOR,MOUNTPOINTS,MOUNTPOINT,PARTTYPENAME,FSTYPE,HOTPLUG|jq --argjson icons_g "$icons_g" --argjson icons "$icons" '.blockdevices|map({
        name:.name,
        path:.path,
        device:{
            vendor:.vendor,
            transport:.tran,
            model:.model
        },
        hotplug:.hotplug,
        icon_g:(if .tran == null then $icons_g["mem"] else $icons_g[.tran] end),
        icon:(if .tran == null then $icons["mem"] else $icons[.tran] end),
        zram:(if .mountpoint == "[SWAP]" then true else false end),
        partitions:(if .children|length > 0 then .children|map({
            label:.label,
            name:.name,
            path:.path,
            partuuid:.partuuid,
            uuid:.uuid,
            type:.fstype,
            parttype:.parttypename,
            hotplug:.hotplug,
            usage:{
                size:.fssize,
                used:.fsused,
                perc:(if ."fsuse%" then ."fsuse%"|sub("%";"")|tonumber else null end)
            },
            mount:.mountpoints,
            mounted:(if .mountpoints.[0] != null or .children.[0].mountpoints.[0] != null then true else false end),
            crypt:(if .fstype == "crypto_LUKS" then true else false end),
            decrypt:(if .fstype == "crypto_LUKS" and .children.[0] != null then .children|map({
                label:.label,
                name:.name,
                path:.path,
                partuuid:.partuuid,
                uuid:.uuid,
                type:.fstype,
                hotplug:.hotplug,
                usage:{
                    size:.fssize,
                    used:.fsused,
                    perc:(if ."fsuse%" then ."fsuse%"|sub("%";"")|tonumber else null end)
                },
                mount:.mountpoints,
                mounted:(if .mountpoints.[0] != null then true else false end)
            }).[0] else null end)
        }) else null end),
    })'
}
function upd(){
    eww -c "$HOME/.config/eww/settings" update disks="$(list)"
}
function eject(){
    if ! udisksctl power-off -b "$1"
    then
        $eww update disk_eject_error=true
    else
        $eww update disk_eject_error=false
    fi
}

function mount(){
    $eww close settings
    if [[ $2 == "swap" ]]
    then
        pkexec swapon "$1"
    fi
    if ! udisksctl mount -b "$1"
    then
        $eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
        $eww update disk_mount_error=true
    else
        $eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
        $eww update disk_mount_error=false
    fi
}
function unmount(){
    $eww close settings
    if [[ $2 == "swap" ]]
    then
        pkexec swapoff "$1"
    fi
    if ! udisksctl unmount -b "$1"
    then
        $eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
        $eww update disk_unmount_error=true
    else
        $eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
        $eww update disk_unmount_error=false
    fi
}
function decrypt(){
    if ! udisksctl unlock -b "$1" --key-file <(echo -n "$2")
    then
        upd
        $eww update disk_decrypt_error=true
        $eww update disk_crypt_passwd=""
    else
        $eww update disk_decrypt_error=false
        upd
        $eww update disk_crypt_passwd=""
    fi
}
function encrypt(){
    if ! udisksctl lock -b "$1"
    then
        upd
        $eww update disk_encrypt_error=true
    else
        $eww update disk_encrypt_error=false
        $eww update disk_decrypt_error=false
        upd
    fi
}

case $1 in
    upd)
        upd
        ;;
    list)
        list;;
    eject)
        eject "$2";;
    mount)
        mount "$2" "$3";;
    unmount)
        unmount "$2" "$3";;
    decrypt)
        decrypt "$2" "$3";;
    encrypt)
        encrypt "$2";;
esac
