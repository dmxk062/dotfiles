#!/bin/bash

function init(){
    if [[ -e "/tmp/.gpudev" ]]
    then
        return
    fi
    for card in /sys/class/drm/card[0-9]
    do
        ln -s "$card" /tmp/.gpudev
    done
}
function nice(){
    numfmt --to=iec $@ 
}

init
path="/tmp/.gpudev/device"
temp="${path}/hwmon/hwmon*"
mem_used=$(< $path/mem_info_vram_used)
mem_total=$(< $path/mem_info_vram_total)
mem_free=$((mem_total - mem_used))
mem_used_nice=$(nice $mem_used)
mem_total_nice=$(nice $mem_total)
mem_free_nice=$(nice $mem_free --round=down)
mem_perc=$(echo "scale=4;($mem_used / $mem_total)*100"|bc )
usage=$(< $path/gpu_busy_percent)
temp=$(< $temp/temp2_input)
temp=${temp::-3}

printf '{"used":%s,"total":%s,"free":%s,"used_nice":"%s","total_nice":"%s","free_nice":"%s","perc":%s,"temp":%s,"utilization":%s}\n' "$mem_used" "$mem_total" "$mem_free" "$mem_used_nice" "$mem_total_nice" "$mem_free_nice" "$mem_perc" "$temp" "$usage"

