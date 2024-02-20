#!/usr/bin/env bash
LOCK_CMD="swaylock --grace=6 --fade-in=5"
LOCK_PRE_SUSPEND_CMD="swaylock"
SLEEP_CMD="systemctl suspend"
# ICON="preferences-desktop-screensaver"
ICON="system-lock-screen"
PIDFILE=/tmp/.swayidle_timeout_pid


function notify_loop() {
    echo $BASHPID > $PIDFILE
    i=30
    id=$(notify-send "Power Management" \
                -a "swayidle" \
                --print-id \
                -i "$ICON" \
                --transient \
                -t 3100 \
                --hint=int:value:$((i*100 / 30 )) \
                "Locking the session in 30 seconds")
    sleep 3
    while ((i >= 3)); do
        ((i-=3))
        if [[ $i == 0 ]]; then
            msg="Locking the session now"
        else
            msg="Locking the session in ${i} seconds"
        fi
        notify-send "Power Management" \
                    -a "swayidle" \
                    -r $id \
                    -i "$ICON" \
                    --transient \
                    -t 3100 \
                    --hint=int:value:$((i*100 / 30 )) \
                    "$msg"
        ((i>=0))&&sleep 3
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

