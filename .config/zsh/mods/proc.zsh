#!/bin/false
# vim: ft=zsh

if [[ "$1" == "unload" ]]; then
    unfunction procmem proccmd
    unalias jobinfo

    return
fi

# process stuff

function procmem {
    local pid

    function get_mem_from_proc {
        local value
        if [[ -r "/proc/$1/status" ]]; then
            read -r _ value _ <<<$(grep "VmRSS" "/proc/$1/status")
            print -- ${value:-0}
        else
            print
        fi
    }

    if (($# == 0)); then
        while read -r pid; do
            get_mem_from_proc "$pid"
        done
    else
        for pid in "$@"; do
            get_mem_from_proc "$pid"
        done
    fi
}

function proccmd {
    local pid
    function get_cmd_from_proc {
        local value
        if [[ -r "/proc/$1/cmdline" ]]; then
            value="$(< /proc/$1/cmdline)"
            print -- ${value//$'\0'/' '}
        else
            print
        fi

    }
    if (($# == 0)); then
        while read -r pid; do
            get_cmd_from_proc "$pid"
        done
    else
        for pid in "$@"; do
            get_cmd_from_proc "$pid"
        done
    fi
}

# very, very verbose wrapper around `time`
alias jobinfo='TIMEFMT="User:     %U
Kernel:   %S
Time:     %E
Usage:    %P
MemMax:   %MK
Input:    %I
Output:   %O
Recv:     %r
Send:     %s
Signals:  %k
Swaps:    %W
Waits:    %w
Switches: %c"
time'
