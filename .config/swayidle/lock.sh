#!/usr/bin/env bash
LOCK_CMD="swaylock"
SLEEP_CMD="systemctl suspend"

if pgrep swaylock; then
    eval "$SLEEP_CMD"
else
    cd
    eval "$LOCK_CMD"
fi
