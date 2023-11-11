#!/bin/bash
CPUTEMP="/sys/devices/platform/asus-ec-sensors/hwmon/*/temp2_input"
# CPUTEMP="/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp1_input"

usage=$(mpstat 1 4 | awk 'END{print 100-$NF}')
temp=$(< $CPUTEMP)
temp=${temp::-3}

printf '{"usage":%s, "temp":%s}\n' "$usage" "$temp"


