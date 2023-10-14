#!/bin/bash
declare -A fsAliases=(
    [raspi_shared]="smb://10.0.0.49/shared/"
    [raspi_open]="smb://10.0.0.49/open/"
    [dmxerv]="sftp://dmxerv/home/ubuntu/storage/"
)
alias=$2
function handleError(){
    if [[ $err -eq 0 ]]
    then
        action="$2"
        status=0
    else
        action="󰒏 failed to $1"
        status=1
    fi
}
target=${fsAliases[$alias]}
case $1 in
    m)
        gio mount "$target"
        err=$?
        handleError "mount remote filesystem $alias" "󰒋 mounted $alias"
        ;;
    u)
        gio mount -u "$target"
        err=$?
        handleError "unmount remote filesystem $alias" "󰒋  unmounted $alias"
        ;;
esac
if [[ $status -eq 0 ]]
then
    lf -remote "send $id echo $action"
else
    lf -remote "send $id echoerr $action"
fi
