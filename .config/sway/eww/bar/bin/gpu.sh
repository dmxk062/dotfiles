#!/usr/bin/env bash 

printf -v GPU "%s" /sys/class/drm/card?
path="$GPU/device"
printf -v temp "%s" "$path/hwmon"/hwmon?

while sleep 4; do
    mem_used=$(numfmt --to=iec < "$path/mem_info_vram_used")
    mem_total=$(numfmt --to=iec < "$path/mem_info_vram_total")
    usage=$(< "$path/gpu_busy_percent")
    temperature=$(< "$temp/temp2_input")
    # truncate away extra precision
    temperature="${temperature::-3}"

    printf '{"mem_used":"%s", "mem_total":"%s", "usage":"%s", "temp": "%s"}\n' \
        "$mem_used" "$mem_total" "$usage" "$temperature"
done
