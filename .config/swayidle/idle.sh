#!/usr/bin/env bash
ICONDIR="/usr/share/icons/Tela/scalable"
LOCK_CMD="swaylock --grace=6 --fade-in=5"
LOCK_PRE_SUSPEND_CMD="swaylock"
SLEEP_CMD="systemctl suspend"
ICON="${ICONDIR}/apps/preferences-desktop-screensaver.svg"
PIDFILE=/tmp/.swayidle_timeout_pid


function notify_loop() {
    echo $BASHPID > $PIDFILE
    i=30
    id=$(notify-send "Power Management" \
                -a "swayidle" \
                --print-id \
                -i "$ICON" \
                -t 5500 \
                "Locking the session in 30 seconds")
    sleep 5
    while ((i >= 5)); do
        ((i-=5))
        notify-send "Power Management" \
                    -a "swayidle" \
                    -r $id \
                    -i "$ICON" \
                    -t 5500 \
                    "Locking the session in ${i} seconds"
        ((i>=0))&&sleep 5
    done
    rm $PIDFILE
}

if [ "$1" == "notify" ]; then
    notify_loop
else
    if pgrep swaylock; then
        eval "$SLEEP_CMD"
    else
        eval "$LOCK_CMD"
    fi
fi

