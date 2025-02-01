#!/usr/bin/env bash

printf -v GPU "%s" /sys/class/drm/card?
path="$GPU/device"

while sleep 3; do
    read -r mem_used < "$path/mem_info_vram_used"
    read -r mem_total < "$path/mem_info_vram_total"
    read -r usage < "$path/gpu_busy_percent" 

    printf '{"mem_used":%s, "mem_total":%s, "usage":%s}\n' \
        "$mem_used" "$mem_total" "$usage"
done
