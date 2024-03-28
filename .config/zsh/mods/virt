#!/bin/false
# vim: ft=zsh


if [[ "$1" == "load" ]] {

function lsvm {
    local connection="${1:-"qemu:///system"}"
    local -A states=(
        ["running"]="on"
        ["idle"]="idle"
        ["paused"]="suspended"
        ["in shutdown"]="shutdown"
        ["shut off"]="off"
        ["crashed"]="crashed"
        ["pmsuspended"]="sleeping"
    )
    local vm id name state
    virsh -c "$connection" list --all|while read -r id name state; do
        if [[ "$id" != "Id" && "$name" != "" ]] {
            print -- "$name\t$states[$state]"
        }
    done
}


function vm {
    local command="$1"
    local target="$2"
    local connection="${3:-"qemu:///system"}"

    virsh -c "$connection" "$command" --domain "$target"
}

function vmgui {
    local vm="${1}"
    local connection="${2-"qemu:///system"}"
    virt-manager --connect qemu:///system --show-domain-console "$vm"
}

function vmguicreat {
    local connection="${1-"qemu:///system"}"
    virt-manager  --show-domain-creator --connect "$connection"

}



alias vsh="virsh -c qemu:///system"

} elif [[ "$1" == "unload" ]] {

unfunction lsvm \
    vm \
    vmgui vmguicreat

unalias vsh

}
