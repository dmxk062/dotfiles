busId="$(lsusb|grep "MTP"|awk '{$4=substr($4,1,length($4)-1)} {print $2","$4}' -)"
case $1 in 
    m)
        gio mount "mtp://[usb:$busId]"
        ;;
    u)
        gio mount "mtp://[usb:$busId]" -u
esac
