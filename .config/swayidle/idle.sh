#!/usr/bin/env bash
LOCK_CMD="swaylock"
SLEEP_CMD="systemctl suspend"
ICON="system-lock-screen"
PIDFILE=/tmp/.swayidle_timeout_pid


function notify_loop() {
    echo $BASHPID > $PIDFILE
    i=20
    id=$(notify-send "Power Management" \
                -a "swayidle" \
                --print-id \
                -i "$ICON" \
                --transient \
                -t 1100 \
                --hint=int:value:$((i*100 / 20 )) \
                "Locking the session in 20 seconds")
    sleep 1
    while ((i >= 1)); do
        ((i-=1))
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
                    -t 1100 \
                    --hint=int:value:$((i*100 / 20 )) \
                    "$msg"
        ((i>=0))&&sleep 1
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

