#!/usr/bin/env bash

BATDEV="/sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:41/PNP0C09:00/PNP0C0A:00/power_supply/BAT0"
max=$(< $BATDEV/energy_full)
percentage=$(< $BATDEV/capacity)
status=$(< $BATDEV/status)
wattage=$(< $BATDEV/power_now)
current=$(< $BATDEV/energy_now)

if [[ $status == "Charging" ]]
then 
    charging=true
else
    charging=false
fi

if $charging
then
    remaining=$((max - current))
else
    remaining=$current
fi
time=$(echo "scale=2; $remaining / $wattage * 60"|bc)
hours=$(echo "$time / 60" | bc)
minutes=$(echo "scale=0; $time % 60" | bc)

LC_NUMERIC="en_US.UTF-8" printf '{"perc":%s,"time":"%.0fh %.0fm","charging":%s,"wattage":%s}' "$percentage" "${hours}" "${minutes}" "$charging" $(echo "scale=2;$wattage / 1000000"|bc)

