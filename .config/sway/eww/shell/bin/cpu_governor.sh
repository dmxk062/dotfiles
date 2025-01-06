#!/bin/sh

echo "$1" |pkexec tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
