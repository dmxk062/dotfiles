#!/bin/bash
CPUTEMP="/sys/devices/platform/asus-ec-sensors/hwmon/*/temp2_input"
# CPUTEMP="/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp1_input"

while true; do
    temp=$(< $CPUTEMP)
    temp=${temp::-3}
    usage=$(mpstat 1 4 --dec=0 | awk 'END{print 100-$NF}')

    printf '{"usage":%s, "temp":%s}\n' "$usage" "$temp"
done
