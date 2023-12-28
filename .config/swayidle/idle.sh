#!/usr/bin/env bash
ICONDIR="/usr/share/icons/Tela/scalable"
LOCK_CMD="swaylock --grace=6 --fade-in=5"
LOCK_PRE_SUSPEND_CMD="swaylock"
SLEEP_CMD="systemctl suspend"
ICON="${ICONDIR}/apps/preferences-desktop-screensaver.svg"

function notify(){
    notify-send "Power Management" \
                -a "swayidle" \
                -i "$ICON" \
                "$2"
}

if [ "$1" == "notify" ]; then
    notify lock "Locking the session in 30 seconds"
else
    if pgrep swaylock; then
        eval "$SLEEP_CMD"
    else
        eval "$LOCK_CMD"
    fi
fi

