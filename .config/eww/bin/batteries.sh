#!/bin/sh

BUSNAME=org.freedesktop.UPower
BASE=/org/freedesktop/UPower

print_devices() {
    busctl --json=short call $BUSNAME $BASE $BUSNAME EnumerateDevices | jq '.data[0][]' -r |
        while read -r dev; do
            busctl --json=short get-property $BUSNAME "$dev" $BUSNAME.Device Percentage Model State TimeToFull TimeToEmpty
        done | jq -rMcs '[ . as $a | range(0; length; 5) | {
            name: $a[.+1].data,
            value: $a[.].data,
            charging: $a[.+2].data == 1,
            to_full: (if $a[.+3].data == 0 then null else $a[.+3].data end),
            to_empty: (if $a[.+4].data == 0 then null else $a[.+4].data end),
        }]'
}

while print_devices ; do
    sleep 6
done
