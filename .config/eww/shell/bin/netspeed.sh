#!/bin/bash
read -r down up <<< "$(LC_ALL=C sar -n DEV 1 1|awk '$1 == "Average:"&& $2 == "enp6s0" {print $5" "$6}')"
function nice(){
    echo $((${1::-3}*1024))|numfmt --to=iec
}
upnice="$(nice $up)"
downnice="$(nice $down)"
printf '{"raw":{"up":%s,"down":%s},"nice":{"up":"%s","down":"%s"}}' "$up" "$down" "$upnice" "$downnice"
