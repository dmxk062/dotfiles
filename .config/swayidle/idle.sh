#!/usr/bin/env bash
ICONDIR="/usr/share/icons/Tela/scalable"
LOCK_CMD="swaylock --grace=6 --fade-in=5"
LOCK_PRE_SUSPEND_CMD="swaylock"
SLEEP_CMD="systemctl suspend"

function notify(){
    case $1 in
        lock)
            icon="${ICONDIR}/apps/preferences-desktop-screensaver.svg";;
        sleep)
            icon="${ICONDIR}/apps/system-suspend.svg";;
    esac
    notify-send "Power Management" \
                -a "swayidle" \
                -i "$icon" \
                "$2"
}

if [ "$1" == "notify" ]; then
    shift
    case $1 in
        lock)
            notify lock "Locking the session in 30 seconds"
            ;;
        suspend)
            notify sleep "Suspending the system in 30 seconds"
            ;;
    esac
else
    case $1 in
        lock)
            $LOCK_CMD
            ;;
        sleep)
            $LOCK_PRE_SUSPEND_CMD
            $SLEEP_CMD
            ;;
        pre)
            $LOCK_PRE_SUSPEND_CMD
            ;;
    esac
fi
