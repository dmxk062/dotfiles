#!/bin/bash
eww="eww -c $HOME/.config/eww/settings"
#lsblk -J --output=LABEL,NAME,PATH,PARTUUID,UUID,TRAN,VENDOR,FSSIZE,FSUSE%,FSUSED,MODEL,VENDOR,MOUNTPOINTS,PARTTYPENAME,FSTYPE
icons_g='{
"sata":"/usr/share/icons/Tela/scalable/devices/drive-harddisk-ieee1394.svg",
"nvme":"/usr/share/icons/Tela/scalable/devices/drive-harddisk-solidstate.svg",
"usb":"/usr/share/icons/Tela/scalable/devices/media-flash-memory-stick.svg",
"default":"/usr/share/icons/Tela/scalable/devices/drive-harddisk.svg",
"mmc":"/usr/share/icons/Tela/scalable/devices/media-flash.svg",
"mem":"/usr/share/icons/Tela/scalable/devices/media-memory.svg"
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
        exit 1
    fi
}

function mount(){
    $eww close settings
    if ! udisksctl mount -b "$1"
    then
        $eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
        exit 1
    fi
    $eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
}
function unmount(){
    $eww close settings
    if ! udisksctl unmount -b "$1"
    then
        $eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
        exit 1
    fi
    $eww open settings --screen $(hyprctl -j monitors|jq '.[]|select(.focused).id')
}
function decrypt(){
    if ! udisksctl unlock -b "$1" --key-file <(echo -n "$2")
    then
        upd
        eww -c "$HOME/.config/eww/settings" update crypt_passwd=""
        exit 1
    fi
    upd
    eww -c "$HOME/.config/eww/settings" update crypt_passwd=""
}
function encrypt(){
    if ! udisksctl lock -b "$1"
    then
        upd
        exit 1
    fi
    upd
}

case $1 in
    upd)
        upd;;
    list)
        list;;
    eject)
        eject "$2";;
    mount)
        mount "$2";;
    unmount)
        unmount "$2";;
    decrypt)
        decrypt "$2" "$3";;
    encrypt)
        encrypt "$2";;
esac
