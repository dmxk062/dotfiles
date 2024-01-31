#!/usr/bin/env bash
. /etc/os-release

get_machine_icon(){
    type=$(< /sys/class/dmi/id/chassis_type)
    case $type in
        3|31)
            echo computer;;
        10|15|23)
            echo computer-laptop;;
        9) 
            echo tablet;;
    esac
}
get_cpu_info(){
    lscpu|awk '
        /Architecture:/{arch=$2}
        $1=="Address"{addr="["$3","$6"]"}
        $1=="Byte"{order=$3}
        $1=="Vendor"{vendor=$3}
        $1=="Model"&&$2=="name:"{model=$4" "$5" "$6}
        $1=="Thread(s)"{tpc=$4}
        $1=="Core(s)"{cores=$4}
        $1=="Socket(s):"{sockets=$2}
        $2=="max"{max_mhz=$4}
        $2=="min"{min_mhz=$4}
        END{
        printf "{\"arch\":\"%s\",\"order\":\"%s\",\"vendor\":\"%s\",\"model\":\"%s\",\"threadsPerCore\":%s,\"coresPerSocket\":%s, \"sockets\":%s, \"min\":%s, \"max\":%s}",arch,order,vendor,model,tpc,cores,sockets,min_mhz,max_mhz
    }'
}
fmt_mem(){
    numfmt --to=iec "$@"
}

get_gpu_info(){
    ports="["
    read -ra gpus <<< $(echo /sys/class/drm/card*)
    gpu="${gpus[0]}"
    for port in "$gpu-"*; do
        if [[ "$(< $port/enabled)" == "enabled" ]]; then
            connector="$(basename "$port"|sed "s/$(basename $gpu)-//")"
            if [[ "$ports" == "[" ]]; then
                ports="[\"$connector\""
            else
                ports="${ports}, \"$connector\""
            fi
        fi
    done
    ports="${ports}]"
    dev="${gpu}/device"
    speed="$(< "$dev/current_link_speed")"
    mem_used="$(< "$dev/mem_info_vram_used")"
    mem_total="$(< "$dev/mem_info_vram_total")"
    mem_used_nice=$(fmt_mem $mem_used)
    mem_total_nice=$(fmt_mem $mem_total)
    source $dev/uevent
    driver="$DRIVER"

    glinfo="$(glxinfo)"
    vendor="$(echo "$glinfo"|grep "OpenGL vendor string")"
    vendor="${vendor##*[[:blank:]]}"
    devline="$(echo "$glinfo"|grep "Device:")"
    start=$(expr index "$devline" ":")
    end=$(expr index "$devline" "()")
    str="${devline:$start+1:$end-$start-3}"
    printf '{"name":"%s", "path":"%s", "vendor":"%s", "link":"%s", "driver":"%s", "mem":{
        "used":%s, "used_nice":"%s", "total":%s, "total_nice":"%s"}, "ports":%s
    }' "$str" "$gpu" "$vendor" "$speed" "$driver" "$mem_used" "$mem_used_nice" "$mem_total" "$mem_total_nice" "$ports"
}

read -r KERNEL HOSTNAME KVERSION ARCH OS <<< "$(uname -srmno)"


PROCESSOR_MODEL="$(< /proc/cpuinfo awk -F: '/^model name[[:space:]]+/ {print $2;exit}'|sed -e 's/ //' -e 's/.-Core Processor.*//')"
PROCESSOR_COUNT="$(nproc --all)"
BOOTTIME="$(awk '/btime/ {print $2}' /proc/stat)"
MEMCOUNT=$(awk '/MemTotal/ {print $2}' /proc/meminfo|numfmt --to=iec --from-unit=1024)
CHASIS_ICON=$(get_machine_icon)
MANUFACTURER="$(< /sys/class/dmi/id/board_vendor)"





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
        "homeUrl":"%s",
        "docUrl":"%s",
        "supportUrl":"%s",
        "icon":"%s",
        "build":"%s"
    },
    "os":{
        "name":"%s",
        "kernel":"%s",
        "version":"%s"
    },
    "platform":{
        "cpu":%s,
        "gpu":%s,
        "vendor":"%s",
        "mem":"%s", 
        "chasis":"%s"
    },
    "windowing":{
        "system":"%s",
        "wm":"%s"
    },
    "user":{
        "boottime":"%s",
        "hostname":"%s",
        "user":"%s"

}
}' "$PRETTY_NAME" "$HOME_URL" "$DOCUMENTATION_URL" "$SUPPORT_URL" "$LOGO" "$BUILD_ID" \
    "$OS" "$KERNEL" "$KVERSION" \
    "$(get_cpu_info)" "$(get_gpu_info)" "$MANUFACTURER" "$MEMCOUNT" "$CHASIS_ICON"\
    "$XDG_BACKEND" "$XDG_CURRENT_DESKTOP"\
    "$BOOTTIME" "$HOSTNAME" "$USER"
)"
