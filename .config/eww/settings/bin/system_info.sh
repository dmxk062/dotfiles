#!/bin/sh

eww="eww -c $HOME/.config/eww/settings"

. /etc/os-release

distro=$ID
distro_name=$PRETTY_NAME
architecture=$(uname -m)
kernel_name=$(uname -s)
kernel_ver=$(uname -r)
processor_vendor="$(< /proc/cpuinfo awk -F: '/^vendor_id[[:space:]]+/ {print $2;exit}')"
processor_model="$(< /proc/cpuinfo awk -F: '/^model name[[:space:]]+/ {print $2;exit}')"
mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo|numfmt --to=iec --from-unit=1024)
windowing_system=$XDG_SESSION_TYPE
window_manager=$XDG_CURRENT_DESKTOP
logo_path="scalable/apps/distributor-logo-"
boottime="$(awk '/btime/ {print $2}' /proc/stat)"
get_logo(){
case $1 in
    arch)
        logo="${logo_path}archlinux.svg";;
    *)
        logo="${logo_path}${distro}.svg"
esac
if [ -f "/usr/share/icons/Tela/$logo" ]
then
    true
else
    like=$(awk -F= '$1 == "ID_LIKE"{print $2}' /etc/os-release|tr -d '"')
    echo "No icon found for $1. using icon for $like"
    get_logo $like
fi
}
get_logo $distro
case $windowing_system in
    wayland)
        windowing_system_logo="scalable/apps/wayland.svg";;
    x11)
        windowing_system_logo="scalable/apps/xorg.svg";;
esac
formatted=$(printf '{"distro":"%s","arch":"%s","cpu_vendor":"%s","cpu_model":"%s","kernel":"%s","kernel_ver":"%s","ram":"%s","windowing_system":"%s","desktop":"%s", "logo":{"distro":"%s", "windowing_system":"%s"}, "boottime":%s}' "$distro_name" "$architecture" \
    "$processor_vendor" "$processor_model" "$kernel_name" "$kernel_ver" "$mem_total" "$windowing_system" "$window_manager" "$logo" "$windowing_system_logo" "$boottime")  

$eww update system="$formatted"
