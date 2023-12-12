#!/usr/bin/env bash
. /etc/os-release

get_icon_name(){
    if [ $ID == "arch" ] || [ $ID_LIKE == "arch" ]; then
        name="archlinux"   
    else 
        name="$ID"
    fi
    echo "distributor-logo-${name}.svg"
}

read -r KERNEL HOSTNAME KVERSION ARCH OS <<< "$(uname -srmno)"

ICON="$(get_icon_name)"

PROCESSOR_MODEL="$(< /proc/cpuinfo awk -F: '/^model name[[:space:]]+/ {print $2;exit}'|sed -e 's/ //' -e 's/.-Core Processor.*//')"
PROCESSOR_COUNT="$(nproc --all)"
BOOTTIME="$(awk '/btime/ {print $2}' /proc/stat)"
MEMCOUNT=$(awk '/MemTotal/ {print $2}' /proc/meminfo|numfmt --to=iec --from-unit=1024)





# printf '{
#     "kernel":"%s",
#     "version":"%s",
#     "architecture":"%s",
#     "operating_system":"%s",
#     "hostname":"%s",
#     "windowing_system":"%s",
#     "windowing_manager":"%s"
# }' "$KERNEL" "$KVERSION" "$ARCH" "$OS" "$HOSTNAME" "$XDG_BACKEND" "$XDG_CURRENT_DESKTOP"

eww -c $XDG_CONFIG_HOME/eww/settings update system="$(printf '{
    "distro":{
        "name":"%s",
        "url":"%s",
        "icon":"%s",
        "build":"%s"
    },
    "os":{
        "name":"%s",
        "kernel":"%s",
        "version":"%s",
        "hostname":"%s"
    },
    "platform":{
        "arch":"%s",
        "cpu":"%s",
        "count":%s,
        "boottime":"%s",
        "mem":"%s"
    },
    "windowing":{
        "system":"%s",
        "wm":"%s"
    }
}' "$PRETTY_NAME" "$HOME_URL" "$ICON" "$BUILD_ID" \
    "$OS" "$KERNEL" "$KVERSION" "$HOSTNAME" \
    "$ARCH" "$PROCESSOR_MODEL" "$PROCESSOR_COUNT" "$BOOTTIME" "$MEMCOUNT" \
    "$XDG_BACKEND" "$XDG_CURRENT_DESKTOP"
)"
