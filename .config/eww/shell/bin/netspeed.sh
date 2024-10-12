#!/bin/zsh
UPMAX=400
DOWNMAX=400
function nice(){
    echo $((${1::-3}*1024))|numfmt --to=iec
}
while true; do
    read -r down up <<< "$(LC_ALL=C sar -n DEV 1 1|awk '$1 == "Average:"&& $2 == "enp6s0" {print $5" "$6}')"
    upnice="$(nice $up)"
    downnice="$(nice $down)"
    if (( down > DOWNMAX)); then
        DOWNMAX=$down
    fi
    if (( up > UPMAX)); then
        UPMAX=$up
    fi
    printf '{"max":{"up":%s, "down":%s}, "raw":{"up":%s,"down":%s},"nice":{"up":"%s","down":"%s"}}\n' \
        "$UPMAX" "$DOWNMAX" "$up" "$down" "$upnice" "$downnice"
    sleep 3
done
